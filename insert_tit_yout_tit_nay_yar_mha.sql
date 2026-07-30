-- ============================================
-- Insert Album "Tit Yout Tit Nay Yar Mha" & WANTED Tracks
-- Run this script in Supabase SQL Editor
-- ============================================

DO $$
DECLARE
  v_wanted_id INT;
  v_layphyu_id INT;
  v_rock_genre_id INT;
  v_album_id INT;
  v_track_id INT;
BEGIN
  -- 1. Ensure Artists exist
  SELECT artist_id INTO v_wanted_id FROM public.Artist_tbl WHERE name = 'WANTED' LIMIT 1;
  IF v_wanted_id IS NULL THEN
    INSERT INTO public.Artist_tbl (name, profile_pic) VALUES ('WANTED', 'https://i.imgur.com/wanted.jpg') RETURNING artist_id INTO v_wanted_id;
  END IF;

  SELECT artist_id INTO v_layphyu_id FROM public.Artist_tbl WHERE name = 'Lay Phyu' LIMIT 1;
  IF v_layphyu_id IS NULL THEN
    INSERT INTO public.Artist_tbl (name, profile_pic) VALUES ('Lay Phyu', 'https://i.imgur.com/layphyu.jpg') RETURNING artist_id INTO v_layphyu_id;
  END IF;

  -- 2. Ensure Rock Genre exists
  SELECT genres_id INTO v_rock_genre_id FROM public.Genres_tbl WHERE name = 'Rock' LIMIT 1;
  IF v_rock_genre_id IS NULL THEN
    INSERT INTO public.Genres_tbl (name) VALUES ('Rock') RETURNING genres_id INTO v_rock_genre_id;
  END IF;

  -- 3. Create Album "Tit Yout Tit Nay Yar Mha"
  INSERT INTO public.Album_tbl (title, release_date, cover_png)
  VALUES ('Tit Yout Tit Nay Yar Mha', '2024-01-01', 'https://i.imgur.com/tityouttitnayyarmha.jpg')
  RETURNING album_id INTO v_album_id;

  -- 4. Link Album to Artist WANTED
  INSERT INTO public.Album_artist_tbl (album_id, artist_id)
  VALUES (v_album_id, v_wanted_id)
  ON CONFLICT DO NOTHING;

  -- 5. Insert Tracks and link to Track_artist_tbl

  -- Track 1: ဝေးခဲ့ရင် - WANTED (Feat. Lay Phyu)
  INSERT INTO public.Track_tbl (album_id, genres_id, title, audio_url, duration, stream_count)
  VALUES (v_album_id, v_rock_genre_id, 'ဝေးခဲ့ရင်', 'https://drive.google.com/file/d/1bn5uo2dWX52D4LuAXYAlOzFBkfhb2D9o/view?usp=drive_web', 240, 0)
  RETURNING track_id INTO v_track_id;
  INSERT INTO public.Track_artist_tbl (track_id, artist_id) VALUES (v_track_id, v_wanted_id), (v_track_id, v_layphyu_id);

  -- Track 2: တစ်နေ့တော့ရောက်မယ် - WANTED
  INSERT INTO public.Track_tbl (album_id, genres_id, title, audio_url, duration, stream_count)
  VALUES (v_album_id, v_rock_genre_id, 'တစ်နေ့တော့ရောက်မယ်', 'https://drive.google.com/file/d/1-QmZtceT2hzHdTy2hvGI_uqOx1riAXX4/view?usp=drive_web', 210, 0)
  RETURNING track_id INTO v_track_id;
  INSERT INTO public.Track_artist_tbl (track_id, artist_id) VALUES (v_track_id, v_wanted_id);

  -- Track 3: ပြောစမ်းဖြေးဖြေး - WANTED
  INSERT INTO public.Track_tbl (album_id, genres_id, title, audio_url, duration, stream_count)
  VALUES (v_album_id, v_rock_genre_id, 'ပြောစမ်းဖြေးဖြေး', 'https://drive.google.com/file/d/1TQ6s5m1i5DNm7xUSdSuYic_EvsWjsaAy/view?usp=drive_web', 225, 0)
  RETURNING track_id INTO v_track_id;
  INSERT INTO public.Track_artist_tbl (track_id, artist_id) VALUES (v_track_id, v_wanted_id);

  -- Track 4: အခုလောလောဆယ် - WANTED
  INSERT INTO public.Track_tbl (album_id, genres_id, title, audio_url, duration, stream_count)
  VALUES (v_album_id, v_rock_genre_id, 'အခုလောလောဆယ်', 'https://drive.google.com/file/d/1xEptqOSN9Nad7HtkoMJIMGgKEe9_jpwK/view?usp=drive_web', 200, 0)
  RETURNING track_id INTO v_track_id;
  INSERT INTO public.Track_artist_tbl (track_id, artist_id) VALUES (v_track_id, v_wanted_id);

  -- Track 5: နောက်ထပ်မညာပါနဲ့ - WANTED
  INSERT INTO public.Track_tbl (album_id, genres_id, title, audio_url, duration, stream_count)
  VALUES (v_album_id, v_rock_genre_id, 'နောက်ထပ်မညာပါနဲ့', 'https://drive.google.com/file/d/10LuFm1QxjuUwfWUoN1RgZVRGkK16rthR/view?usp=drive_web', 230, 0)
  RETURNING track_id INTO v_track_id;
  INSERT INTO public.Track_artist_tbl (track_id, artist_id) VALUES (v_track_id, v_wanted_id);

  -- Track 6: ခဏလေး - WANTED
  INSERT INTO public.Track_tbl (album_id, genres_id, title, audio_url, duration, stream_count)
  VALUES (v_album_id, v_rock_genre_id, 'ခဏလေး', 'https://drive.google.com/file/d/1BzDuttE3v-fTEgmcpqufOi4i4bIGxGQV/view?usp=drive_web', 195, 0)
  RETURNING track_id INTO v_track_id;
  INSERT INTO public.Track_artist_tbl (track_id, artist_id) VALUES (v_track_id, v_wanted_id);

  -- Track 7: ငတေ (ငရဲမီး) - WANTED
  INSERT INTO public.Track_tbl (album_id, genres_id, title, audio_url, duration, stream_count)
  VALUES (v_album_id, v_rock_genre_id, 'ငတေ (ငရဲမီး)', 'https://drive.google.com/file/d/1gMjmwfMohdAtCHK7oD2HouNZFZ4b3iK9/view?usp=drive_web', 245, 0)
  RETURNING track_id INTO v_track_id;
  INSERT INTO public.Track_artist_tbl (track_id, artist_id) VALUES (v_track_id, v_wanted_id);

  -- Track 8: ကိုယ့်သေတွင်းကိုယ် - WANTED
  INSERT INTO public.Track_tbl (album_id, genres_id, title, audio_url, duration, stream_count)
  VALUES (v_album_id, v_rock_genre_id, 'ကိုယ့်သေတွင်းကိုယ်', 'https://drive.google.com/file/d/15sBKt-dav9mcSAPWKZhs-qGFnkLW2tDb/view?usp=drive_web', 215, 0)
  RETURNING track_id INTO v_track_id;
  INSERT INTO public.Track_artist_tbl (track_id, artist_id) VALUES (v_track_id, v_wanted_id);

  -- Track 9: အကောင်းအဆုံးအကြံ - WANTED
  INSERT INTO public.Track_tbl (album_id, genres_id, title, audio_url, duration, stream_count)
  VALUES (v_album_id, v_rock_genre_id, 'အကောင်းအဆုံးအကြံ', 'https://drive.google.com/file/d/19bDIegCOGcCznZapqxgB2-XHMCvXI1ow/view?usp=drive_web', 220, 0)
  RETURNING track_id INTO v_track_id;
  INSERT INTO public.Track_artist_tbl (track_id, artist_id) VALUES (v_track_id, v_wanted_id);

  -- Track 10: ငါ့ကုသိုလ်ကံ - WANTED
  INSERT INTO public.Track_tbl (album_id, genres_id, title, audio_url, duration, stream_count)
  VALUES (v_album_id, v_rock_genre_id, 'ငါ့ကုသိုလ်ကံ', 'https://drive.google.com/file/d/1b3A8pdrN_A92blKIPdY3b4Q2TdwCBe7g/view?usp=drive_web', 205, 0)
  RETURNING track_id INTO v_track_id;
  INSERT INTO public.Track_artist_tbl (track_id, artist_id) VALUES (v_track_id, v_wanted_id);

  -- Track 11: အယူမသီးနဲ့ - WANTED
  INSERT INTO public.Track_tbl (album_id, genres_id, title, audio_url, duration, stream_count)
  VALUES (v_album_id, v_rock_genre_id, 'အယူမသီးနဲ့', 'https://drive.google.com/file/d/150sx9zZfxBfUarPaAoHoBql1CSAvuGcz/view?usp=drive_web', 210, 0)
  RETURNING track_id INTO v_track_id;
  INSERT INTO public.Track_artist_tbl (track_id, artist_id) VALUES (v_track_id, v_wanted_id);

  -- Track 12: နှုတ်ဆက်တေး - WANTED
  INSERT INTO public.Track_tbl (album_id, genres_id, title, audio_url, duration, stream_count)
  VALUES (v_album_id, v_rock_genre_id, 'နှုတ်ဆက်တေး', 'https://drive.google.com/file/d/1RIkGUX2jfZa5Vox6kp3xb1g3kezz27js/view?usp=drive_web', 235, 0)
  RETURNING track_id INTO v_track_id;
  INSERT INTO public.Track_artist_tbl (track_id, artist_id) VALUES (v_track_id, v_wanted_id);

  -- Track 13: အဖေ့အိမ် - WANTED
  INSERT INTO public.Track_tbl (album_id, genres_id, title, audio_url, duration, stream_count)
  VALUES (v_album_id, v_rock_genre_id, 'အဖေ့အိမ်', 'https://drive.google.com/file/d/1EyqOgpYv8v28wJTximrZvUwDgQI7SVvJ/view?usp=drive_web', 250, 0)
  RETURNING track_id INTO v_track_id;
  INSERT INTO public.Track_artist_tbl (track_id, artist_id) VALUES (v_track_id, v_wanted_id);

  -- Track 14: မိုက်မဲသူ - WANTED
  INSERT INTO public.Track_tbl (album_id, genres_id, title, audio_url, duration, stream_count)
  VALUES (v_album_id, v_rock_genre_id, 'မိုက်မဲသူ', 'https://drive.google.com/file/d/1i1aTPq7IbSjtESTvXXJwrrAIe9m16Drs/view?usp=drive_web', 220, 0)
  RETURNING track_id INTO v_track_id;
  INSERT INTO public.Track_artist_tbl (track_id, artist_id) VALUES (v_track_id, v_wanted_id);

  -- Track 15: သံယောဇဉ်ဖြတ်တဲ့နည်း - WANTED
  INSERT INTO public.Track_tbl (album_id, genres_id, title, audio_url, duration, stream_count)
  VALUES (v_album_id, v_rock_genre_id, 'သံယောဇဉ်ဖြတ်တဲ့နည်း', 'https://drive.google.com/file/d/1ZTyO0c5BBNHMwIqU-4L_ca-gYlrjQ93D/view?usp=drive_web', 240, 0)
  RETURNING track_id INTO v_track_id;
  INSERT INTO public.Track_artist_tbl (track_id, artist_id) VALUES (v_track_id, v_wanted_id);

  -- Track 16: ခွင့်လွှတ်ထားပါတယ် - WANTED
  INSERT INTO public.Track_tbl (album_id, genres_id, title, audio_url, duration, stream_count)
  VALUES (v_album_id, v_rock_genre_id, 'ခွင့်လွှတ်ထားပါတယ်', 'https://drive.google.com/file/d/1xiW1UNJuojEKhFVekENgBB17e10aQCRn/view?usp=drive_web', 230, 0)
  RETURNING track_id INTO v_track_id;
  INSERT INTO public.Track_artist_tbl (track_id, artist_id) VALUES (v_track_id, v_wanted_id);

  -- Track 17: ရေစက် - WANTED
  INSERT INTO public.Track_tbl (album_id, genres_id, title, audio_url, duration, stream_count)
  VALUES (v_album_id, v_rock_genre_id, 'ရေစက်', 'https://drive.google.com/file/d/1vpuvQU5UGU1GTmnk0i919WPwvhfERRgG/view?usp=drive_web', 225, 0)
  RETURNING track_id INTO v_track_id;
  INSERT INTO public.Track_artist_tbl (track_id, artist_id) VALUES (v_track_id, v_wanted_id);

END $$;
