-- ============================================
-- Sonus Music App - Database Schema
-- Run this in Supabase SQL Editor
-- Parent tables first, then children/junction
-- ============================================

-- 1. Drop existing tables (child first, then parent)
DROP TABLE IF EXISTS public.User_like_tbl CASCADE;
DROP TABLE IF EXISTS public.Playlist_track_tbl CASCADE;
DROP TABLE IF EXISTS public.Playlist_tbl CASCADE;
DROP TABLE IF EXISTS public.Track_tbl CASCADE;
DROP TABLE IF EXISTS public.Album_tbl CASCADE;
DROP TABLE IF EXISTS public.Genres_tbl CASCADE;
DROP TABLE IF EXISTS public.Artist_tbl CASCADE;
DROP TABLE IF EXISTS public.User_tbl CASCADE;

-- ============================================
-- PARENT TABLES (no foreign keys)
-- ============================================

-- 2. User_tbl
CREATE TABLE public.User_tbl (
  user_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL DEFAULT '',
  role TEXT NOT NULL DEFAULT 'user'
);

-- 3. Artist_tbl
CREATE TABLE public.Artist_tbl (
  artist_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name TEXT NOT NULL,
  profile_pic TEXT
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
CREATE TABLE public.Album_tbl (
  album_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  artist_id INT NOT NULL REFERENCES public.Artist_tbl(artist_id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  release_date INT,
  cover_png TEXT
);

-- 6. Track_tbl
CREATE TABLE public.Track_tbl (
  track_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  artist_id INT NOT NULL REFERENCES public.Artist_tbl(artist_id) ON DELETE CASCADE,
  album_id INT NOT NULL REFERENCES public.Album_tbl(album_id) ON DELETE CASCADE,
  genres_id INT NOT NULL REFERENCES public.Genres_tbl(genres_id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  duration INT NOT NULL DEFAULT 0,
  stream_count INT NOT NULL DEFAULT 0
);

-- 7. Playlist_tbl
CREATE TABLE public.Playlist_tbl (
  playlist_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id INT NOT NULL REFERENCES public.User_tbl(user_id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  cover_png TEXT
);

-- ============================================
-- JUNCTION / RELATIONSHIP TABLES
-- ============================================

-- 8. Playlist_track_tbl
CREATE TABLE public.Playlist_track_tbl (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  playlist_id INT NOT NULL REFERENCES public.Playlist_tbl(playlist_id) ON DELETE CASCADE,
  track_id INT NOT NULL REFERENCES public.Track_tbl(track_id) ON DELETE CASCADE
);

-- 9. User_like_tbl
CREATE TABLE public.User_like_tbl (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id INT NOT NULL REFERENCES public.User_tbl(user_id) ON DELETE CASCADE,
  track_id INT NOT NULL REFERENCES public.Track_tbl(track_id) ON DELETE CASCADE,
  like_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ============================================
-- INDEXES for common query patterns
-- ============================================

CREATE INDEX idx_album_artist ON public.Album_tbl(artist_id);
CREATE INDEX idx_track_artist ON public.Track_tbl(artist_id);
CREATE INDEX idx_track_album ON public.Track_tbl(album_id);
CREATE INDEX idx_track_genre ON public.Track_tbl(genres_id);
CREATE INDEX idx_playlist_user ON public.Playlist_tbl(user_id);
CREATE INDEX idx_playlist_track_playlist ON public.Playlist_track_tbl(playlist_id);
CREATE INDEX idx_playlist_track_track ON public.Playlist_track_tbl(track_id);
CREATE INDEX idx_user_like_user ON public.User_like_tbl(user_id);
CREATE INDEX idx_user_like_track ON public.User_like_tbl(track_id);
