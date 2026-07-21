-- ============================================
-- Sonus Music App - Database Schema
-- Run this in Supabase SQL Editor
-- Fixed to match Flutter code expectations
-- ============================================

-- 1. Drop existing tables (child first, then parent)
DROP TABLE IF EXISTS public.User_like_tbl CASCADE;
DROP TABLE IF EXISTS public.Playlist_track_tbl CASCADE;
DROP TABLE IF EXISTS public.Playlist_tbl CASCADE;
DROP TABLE IF EXISTS public.Track_artist_tbl CASCADE;
DROP TABLE IF EXISTS public.Track_tbl CASCADE;
DROP TABLE IF EXISTS public.Album_artist_tbl CASCADE;
DROP TABLE IF EXISTS public.Album_tbl CASCADE;
DROP TABLE IF EXISTS public.Genres_tbl CASCADE;
DROP TABLE IF EXISTS public.Artist_tbl CASCADE;
DROP TABLE IF EXISTS public.User_tbl CASCADE;

-- Drop existing functions
DROP FUNCTION IF EXISTS public.increment_stream_count(INT);

-- ============================================
-- PARENT TABLES (no foreign keys)
-- ============================================

-- 2. User_tbl
-- user_id is TEXT because Supabase Auth uses UUID strings
CREATE TABLE public.User_tbl (
  user_id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL DEFAULT '',
  role TEXT NOT NULL DEFAULT 'user',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 3. Artist_tbl
CREATE TABLE public.Artist_tbl (
  artist_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name TEXT NOT NULL,
  profile_pic TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 4. Genres_tbl
CREATE TABLE public.Genres_tbl (
  genres_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name TEXT NOT NULL
);

-- ============================================
-- CHILD TABLES (foreign keys reference parents)
-- ============================================

-- 5. Album_tbl
-- No artist_id here — artists linked via Album_artist_tbl junction
-- release_date is TEXT to accept date strings like '2015-03-15'
CREATE TABLE public.Album_tbl (
  album_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title TEXT NOT NULL,
  release_date TEXT,
  cover_png TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 6. Album_artist_tbl (junction: albums ↔ artists)
CREATE TABLE public.Album_artist_tbl (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  album_id INT NOT NULL REFERENCES public.Album_tbl(album_id) ON DELETE CASCADE,
  artist_id INT NOT NULL REFERENCES public.Artist_tbl(artist_id) ON DELETE CASCADE,
  UNIQUE(album_id, artist_id)
);

-- 7. Track_tbl
-- No artist_id here — artists linked via Track_artist_tbl junction
-- audio_url is required by AudioProvider to play tracks
CREATE TABLE public.Track_tbl (
  track_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  album_id INT NOT NULL REFERENCES public.Album_tbl(album_id) ON DELETE CASCADE,
  genres_id INT NOT NULL REFERENCES public.Genres_tbl(genres_id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  audio_url TEXT NOT NULL DEFAULT '',
  duration INT NOT NULL DEFAULT 0,
  stream_count INT NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 8. Track_artist_tbl (junction: tracks ↔ artists)
CREATE TABLE public.Track_artist_tbl (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  track_id INT NOT NULL REFERENCES public.Track_tbl(track_id) ON DELETE CASCADE,
  artist_id INT NOT NULL REFERENCES public.Artist_tbl(artist_id) ON DELETE CASCADE,
  UNIQUE(track_id, artist_id)
);

-- ============================================
-- USER-OWNED TABLES
-- ============================================

-- 9. Playlist_tbl
CREATE TABLE public.Playlist_tbl (
  playlist_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES public.User_tbl(user_id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  cover_png TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ============================================
-- JUNCTION / RELATIONSHIP TABLES
-- ============================================

-- 10. Playlist_track_tbl
CREATE TABLE public.Playlist_track_tbl (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  playlist_id INT NOT NULL REFERENCES public.Playlist_tbl(playlist_id) ON DELETE CASCADE,
  track_id INT NOT NULL REFERENCES public.Track_tbl(track_id) ON DELETE CASCADE,
  added_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 11. User_like_tbl
CREATE TABLE public.User_like_tbl (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES public.User_tbl(user_id) ON DELETE CASCADE,
  track_id INT NOT NULL REFERENCES public.Track_tbl(track_id) ON DELETE CASCADE,
  like_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ============================================
-- RPC FUNCTION: increment_stream_count
-- Called by TrackProvider.incrementStreamCount()
-- ============================================

CREATE OR REPLACE FUNCTION public.increment_stream_count(tid INT)
RETURNS VOID AS $$
BEGIN
  UPDATE public.Track_tbl
  SET stream_count = stream_count + 1
  WHERE track_id = tid;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- INDEXES for common query patterns
-- ============================================

CREATE INDEX idx_album_artist_album ON public.Album_artist_tbl(album_id);
CREATE INDEX idx_album_artist_artist ON public.Album_artist_tbl(artist_id);
CREATE INDEX idx_track_artist_track ON public.Track_artist_tbl(track_id);
CREATE INDEX idx_track_artist_artist ON public.Track_artist_tbl(artist_id);
CREATE INDEX idx_track_album ON public.Track_tbl(album_id);
CREATE INDEX idx_track_genre ON public.Track_tbl(genres_id);
CREATE INDEX idx_playlist_user ON public.Playlist_tbl(user_id);
CREATE INDEX idx_playlist_track_playlist ON public.Playlist_track_tbl(playlist_id);
CREATE INDEX idx_playlist_track_track ON public.Playlist_track_tbl(track_id);
CREATE INDEX idx_user_like_user ON public.User_like_tbl(user_id);
CREATE INDEX idx_user_like_track ON public.User_like_tbl(track_id);

-- ============================================
-- ROW LEVEL SECURITY (optional but recommended)
-- ============================================

ALTER TABLE public.User_tbl ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.Artist_tbl ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.Genres_tbl ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.Album_tbl ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.Album_artist_tbl ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.Track_tbl ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.Track_artist_tbl ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.Playlist_tbl ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.Playlist_track_tbl ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.User_like_tbl ENABLE ROW LEVEL SECURITY;

-- Allow public read access for music data
CREATE POLICY "Public read access" ON public.Artist_tbl FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.Genres_tbl FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.Album_tbl FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.Album_artist_tbl FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.Track_tbl FOR SELECT USING (true);
CREATE POLICY "Public read access" ON public.Track_artist_tbl FOR SELECT USING (true);

-- Authenticated user policies
CREATE POLICY "Users can read own profile" ON public.User_tbl FOR SELECT USING (auth.uid()::text = user_id);
CREATE POLICY "Users can update own profile" ON public.User_tbl FOR UPDATE USING (auth.uid()::text = user_id);
CREATE POLICY "Users can insert own profile" ON public.User_tbl FOR INSERT WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can manage own playlists" ON public.Playlist_tbl FOR ALL USING (auth.uid()::text = user_id);
CREATE POLICY "Users can manage own playlist tracks" ON public.Playlist_track_tbl FOR ALL
  USING (playlist_id IN (SELECT playlist_id FROM public.Playlist_tbl WHERE user_id = auth.uid()::text));

CREATE POLICY "Users can manage own likes" ON public.User_like_tbl FOR ALL USING (auth.uid()::text = user_id);

-- Admin policies (admin role check)
CREATE POLICY "Admins can manage users" ON public.User_tbl FOR ALL
  USING (EXISTS (SELECT 1 FROM public.User_tbl WHERE user_id = auth.uid()::text AND role = 'admin'));
CREATE POLICY "Admins can manage artists" ON public.Artist_tbl FOR ALL
  USING (EXISTS (SELECT 1 FROM public.User_tbl WHERE user_id = auth.uid()::text AND role = 'admin'));
CREATE POLICY "Admins can manage albums" ON public.Album_tbl FOR ALL
  USING (EXISTS (SELECT 1 FROM public.User_tbl WHERE user_id = auth.uid()::text AND role = 'admin'));
CREATE POLICY "Admins can manage album artists" ON public.Album_artist_tbl FOR ALL
  USING (EXISTS (SELECT 1 FROM public.User_tbl WHERE user_id = auth.uid()::text AND role = 'admin'));
CREATE POLICY "Admins can manage tracks" ON public.Track_tbl FOR ALL
  USING (EXISTS (SELECT 1 FROM public.User_tbl WHERE user_id = auth.uid()::text AND role = 'admin'));
CREATE POLICY "Admins can manage track artists" ON public.Track_artist_tbl FOR ALL
  USING (EXISTS (SELECT 1 FROM public.User_tbl WHERE user_id = auth.uid()::text AND role = 'admin'));
