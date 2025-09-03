-- Location: supabase/migrations/20241216204355_content_management_system.sql
-- Schema Analysis: Creating comprehensive content management system
-- Integration Type: complete system with authentication
-- Dependencies: auth.users (Supabase built-in)

-- 1. Types and Enums
CREATE TYPE public.user_role AS ENUM ('admin', 'moderator', 'member');
CREATE TYPE public.message_status AS ENUM ('unread', 'read', 'archived');
CREATE TYPE public.comment_status AS ENUM ('approved', 'pending', 'rejected');
CREATE TYPE public.priority_level AS ENUM ('low', 'medium', 'high', 'urgent');

-- 2. Core Tables
-- Critical intermediary table for PostgREST compatibility
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    username TEXT UNIQUE,
    role public.user_role DEFAULT 'member'::public.user_role,
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Messages table for inbox functionality
CREATE TABLE public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    recipient_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    subject TEXT NOT NULL,
    content TEXT NOT NULL,
    status public.message_status DEFAULT 'unread'::public.message_status,
    priority public.priority_level DEFAULT 'medium'::public.priority_level,
    has_attachments BOOLEAN DEFAULT false,
    replied_to UUID REFERENCES public.messages(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Content posts for comment management
CREATE TABLE public.posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    excerpt TEXT,
    slug TEXT UNIQUE,
    is_published BOOLEAN DEFAULT false,
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Comments system
CREATE TABLE public.comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE,
    author_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES public.comments(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    status public.comment_status DEFAULT 'pending'::public.comment_status,
    like_count INTEGER DEFAULT 0,
    is_edited BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Analytics for dashboard
CREATE TABLE public.user_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    messages_sent INTEGER DEFAULT 0,
    messages_received INTEGER DEFAULT 0,
    comments_posted INTEGER DEFAULT 0,
    posts_created INTEGER DEFAULT 0,
    last_activity TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_username ON public.user_profiles(username);
CREATE INDEX idx_messages_recipient ON public.messages(recipient_id);
CREATE INDEX idx_messages_sender ON public.messages(sender_id);
CREATE INDEX idx_messages_status ON public.messages(status);
CREATE INDEX idx_posts_author ON public.posts(author_id);
CREATE INDEX idx_posts_slug ON public.posts(slug);
CREATE INDEX idx_comments_post ON public.comments(post_id);
CREATE INDEX idx_comments_author ON public.comments(author_id);
CREATE INDEX idx_comments_status ON public.comments(status);
CREATE INDEX idx_user_analytics_user ON public.user_analytics(user_id);

-- 4. Functions (Must be before RLS policies)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name, username, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
        COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'member'::public.user_role)
    );

    INSERT INTO public.user_analytics (user_id)
    VALUES (NEW.id);

    RETURN NEW;
END;
$$;

-- Function to update analytics
CREATE OR REPLACE FUNCTION public.update_user_analytics()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_TABLE_NAME = 'messages' AND TG_OP = 'INSERT' THEN
        -- Update sender stats
        UPDATE public.user_analytics
        SET messages_sent = messages_sent + 1,
            last_activity = NOW(),
            updated_at = NOW()
        WHERE user_id = NEW.sender_id;
        
        -- Update recipient stats
        UPDATE public.user_analytics
        SET messages_received = messages_received + 1,
            updated_at = NOW()
        WHERE user_id = NEW.recipient_id;
    END IF;

    IF TG_TABLE_NAME = 'comments' AND TG_OP = 'INSERT' THEN
        UPDATE public.user_analytics
        SET comments_posted = comments_posted + 1,
            last_activity = NOW(),
            updated_at = NOW()
        WHERE user_id = NEW.author_id;

        UPDATE public.posts
        SET comment_count = comment_count + 1,
            updated_at = NOW()
        WHERE id = NEW.post_id;
    END IF;

    IF TG_TABLE_NAME = 'posts' AND TG_OP = 'INSERT' THEN
        UPDATE public.user_analytics
        SET posts_created = posts_created + 1,
            last_activity = NOW(),
            updated_at = NOW()
        WHERE user_id = NEW.author_id;
    END IF;

    RETURN NEW;
END;
$$;

-- 5. RLS Setup
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_analytics ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policies following the 7-pattern system

-- Pattern 1: Core user table (user_profiles) - Simple only, no functions
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 2: Simple user ownership for messages
CREATE POLICY "users_manage_own_messages"
ON public.messages
FOR ALL
TO authenticated
USING (sender_id = auth.uid() OR recipient_id = auth.uid())
WITH CHECK (sender_id = auth.uid());

-- Pattern 2: Simple user ownership for posts
CREATE POLICY "users_manage_own_posts"
ON public.posts
FOR ALL
TO authenticated
USING (author_id = auth.uid())
WITH CHECK (author_id = auth.uid());

-- Pattern 4: Public read, private write for comments
CREATE POLICY "public_can_read_comments"
ON public.comments
FOR SELECT
TO public
USING (true);

CREATE POLICY "users_manage_own_comments"
ON public.comments
FOR INSERT, UPDATE, DELETE
TO authenticated
USING (author_id = auth.uid())
WITH CHECK (author_id = auth.uid());

-- Pattern 2: Simple user ownership for analytics
CREATE POLICY "users_manage_own_analytics"
ON public.user_analytics
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 7. Triggers
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER on_message_created
    AFTER INSERT ON public.messages
    FOR EACH ROW EXECUTE FUNCTION public.update_user_analytics();

CREATE TRIGGER on_comment_created
    AFTER INSERT ON public.comments
    FOR EACH ROW EXECUTE FUNCTION public.update_user_analytics();

CREATE TRIGGER on_post_created
    AFTER INSERT ON public.posts
    FOR EACH ROW EXECUTE FUNCTION public.update_user_analytics();

-- 8. Complete Mock Data
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    user1_uuid UUID := gen_random_uuid();
    user2_uuid UUID := gen_random_uuid();
    post1_uuid UUID := gen_random_uuid();
    post2_uuid UUID := gen_random_uuid();
BEGIN
    -- Create auth users with required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@contentflow.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User", "username": "admin", "role": "admin"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user1_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'john.doe@example.com', crypt('user123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "John Doe", "username": "johndoe", "role": "member"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user2_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'jane.smith@example.com', crypt('user123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Jane Smith", "username": "janesmith", "role": "moderator"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create sample posts
    INSERT INTO public.posts (id, author_id, title, content, excerpt, slug, is_published) VALUES
        (post1_uuid, admin_uuid, 'Welcome to ContentFlow Pro', 'This is our comprehensive content management platform with advanced messaging and collaboration features.', 'Welcome guide to ContentFlow Pro platform', 'welcome-to-contentflow-pro', true),
        (post2_uuid, user1_uuid, 'Getting Started Guide', 'Learn how to navigate the dashboard, manage your inbox, and moderate comments effectively.', 'Complete getting started guide', 'getting-started-guide', true);

    -- Create sample messages
    INSERT INTO public.messages (sender_id, recipient_id, subject, content, priority) VALUES
        (admin_uuid, user1_uuid, 'Welcome to ContentFlow Pro!', 'Welcome to our platform! We are excited to have you on board. Feel free to explore all the features.', 'high'::public.priority_level),
        (user1_uuid, admin_uuid, 'Thank you for the welcome', 'Thank you for the warm welcome. I am looking forward to using this platform.', 'medium'::public.priority_level),
        (admin_uuid, user2_uuid, 'Moderator Access Granted', 'You have been granted moderator access. You can now manage comments and moderate content.', 'high'::public.priority_level),
        (user2_uuid, user1_uuid, 'Collaboration Request', 'Would you like to collaborate on the upcoming content series? Let me know your thoughts.', 'medium'::public.priority_level);

    -- Create sample comments
    INSERT INTO public.comments (post_id, author_id, content, status) VALUES
        (post1_uuid, user1_uuid, 'Great platform! Looking forward to exploring all features.', 'approved'::public.comment_status),
        (post1_uuid, user2_uuid, 'The messaging system is very intuitive and well-designed.', 'approved'::public.comment_status),
        (post2_uuid, user1_uuid, 'This guide is very helpful for new users. Thank you!', 'pending'::public.comment_status),
        (post2_uuid, admin_uuid, 'Thanks for the feedback! We will keep improving the guides.', 'approved'::public.comment_status);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;