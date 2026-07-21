-- ============================================
-- Sonus Music App - Myanmar Music Seed Data
-- Run this in Supabase SQL Editor AFTER schema
-- ============================================

-- ─── Genres ────────────────────────────────
INSERT INTO public.Genres_tbl (name) VALUES
  ('Rock'),
  ('Pop'),
  ('Hip Hop'),
  ('Ballad'),
  ('R&B'),
  ('Folk'),
  ('Indie'),
  ('Alternative');

-- ─── Artists ───────────────────────────────
INSERT INTO public.Artist_tbl (name, profile_pic) VALUES
  ('Iron Cross', 'https://i.imgur.com/ironcross.jpg'),
  ('Beyond The Black', 'https://i.imgur.com/btb.jpg'),
  ('Sai Sai Kham Leng', 'https://i.imgur.com/saisai.jpg'),
  ('R Zarni', 'https://i.imgur.com/rzarni.jpg'),
  ('Phyu Phyu Kyaw Thein', 'https://i.imgur.com/ppkt.jpg'),
  ('Hlwan Paing', 'https://i.imgur.com/hlwanpaing.jpg'),
  ('Hein Wunna', 'https://i.imgur.com/heinwunna.jpg'),
  ('Oak Soe Khant', 'https://i.imgur.com/oaksoekhant.jpg'),
  ('Yi Wyet', 'https://i.imgur.com/yiwyet.jpg'),
  ('Reksha', 'https://i.imgur.com/reksha.jpg'),
  ('Thar Eth', 'https://i.imgur.com/thareth.jpg'),
  ('Nyemak', 'https://i.imgur.com/nyemak.jpg');

-- ─── Albums ────────────────────────────────
INSERT INTO public.Album_tbl (title, release_date, cover_png) VALUES
  ('Rock Oo Kya', '2015-03-15', 'https://i.imgur.com/rockookya.jpg'),
  ('Kyal Sin', '2018-07-20', 'https://i.imgur.com/kyalsin.jpg'),
  ('Shwe Hmone', '2020-01-10', 'https://i.imgur.com/shwehmone.jpg'),
  ('Yee Sar', '2019-06-05', 'https://i.imgur.com/yeesar.jpg'),
  ('Pyar Chit', '2021-02-14', 'https://i.imgur.com/pyarchit.jpg'),
  ('My World', '2017-11-30', 'https://i.imgur.com/myworld.jpg'),
  ('Thit Sar', '2020-08-25', 'https://i.imgur.com/thitsar.jpg'),
  ('Nway Oo', '2022-04-01', 'https://i.imgur.com/nwayoo.jpg'),
  ('Ko Htike', '2016-09-12', 'https://i.imgur.com/kohtike.jpg'),
  ('A Chin Taung', '2019-12-20', 'https://i.imgur.com/achintaung.jpg'),
  ('Hlaing Bwar', '2021-07-15', 'https://i.imgur.com/hlaingbwar.jpg'),
  ('Memory', '2023-01-05', 'https://i.imgur.com/memory.jpg');

-- ─── Album-Artist Junction ─────────────────
INSERT INTO public.Album_artist_tbl (album_id, artist_id) VALUES
  (1, 1),   -- Rock Oo Kya → Iron Cross
  (2, 2),   -- Kyal Sin → Beyond The Black
  (3, 3),   -- Shwe Hmone → Sai Sai Kham Leng
  (4, 4),   -- Yee Sar → R Zarni
  (5, 5),   -- Pyar Chit → Phyu Phyu Kyaw Thein
  (6, 6),   -- My World → Hlwan Paing
  (7, 7),   -- Thit Sar → Hein Wunna
  (8, 8),   -- Nway Oo → Oak Soe Khant
  (9, 9),   -- Ko Htike → Yi Wyet
  (10, 10), -- A Chin Taung → Reksha
  (11, 11), -- Hlaing Bwar → Thar Eth
  (12, 12); -- Memory → Nyemak

-- ─── Tracks ────────────────────────────────
INSERT INTO public.Track_tbl (album_id, genres_id, title, audio_url, duration, stream_count) VALUES
  -- Rock Oo Kya (Album 1, Iron Cross)
  (1, 1, 'Rock Oo Kya', 'https://example.com/audio/rock_oo_kya.mp3', 245, 125000),
  (1, 1, 'A Chit Kwar', 'https://example.com/audio/a_chit_kwar.mp3', 210, 98000),
  (1, 8, 'Ma Shi Bu', 'https://example.com/audio/ma_shi_bu.mp3', 195, 87000),

  -- Kyal Sin (Album 2, Beyond The Black)
  (2, 1, 'Kyal Sin', 'https://example.com/audio/kyal_sin.mp3', 260, 156000),
  (2, 1, 'A Mhar A Yat', 'https://example.com/audio/a_mhar_a_yat.mp3', 230, 112000),
  (2, 8, 'Pyan Pyar', 'https://example.com/audio/pyan_pyar.mp3', 200, 89000),

  -- Shwe Hmone (Album 3, Sai Sai Kham Leng)
  (3, 3, 'Shwe Hmone', 'https://example.com/audio/shwe_hmone.mp3', 220, 201000),
  (3, 3, 'Tha Mee', 'https://example.com/audio/tha_mee.mp3', 190, 178000),
  (3, 3, 'Kyal Sin Lay', 'https://example.com/audio/kyal_sin_lay.mp3', 215, 145000),

  -- Yee Sar (Album 4, R Zarni)
  (4, 2, 'Yee Sar', 'https://example.com/audio/yee_sar.mp3', 235, 167000),
  (4, 2, 'Ngar Bar', 'https://example.com/audio/ngar_bar.mp3', 205, 134000),
  (4, 4, 'Chit Thu', 'https://example.com/audio/chit_thu.mp3', 250, 156000),

  -- Pyar Chit (Album 5, Phyu Phyu Kyaw Thein)
  (5, 4, 'Pyar Chit', 'https://example.com/audio/pyar_chit.mp3', 280, 189000),
  (5, 4, 'Naing Ngan', 'https://example.com/audio/naing_ngan.mp3', 240, 145000),
  (5, 5, 'A Kyat Phan', 'https://example.com/audio/a_kyat_phan.mp3', 225, 112000),

  -- My World (Album 6, Hlwan Paing)
  (6, 2, 'My World', 'https://example.com/audio/my_world.mp3', 210, 178000),
  (6, 2, 'A Thi Li', 'https://example.com/audio/a_thi_li.mp3', 195, 156000),
  (6, 5, 'Thar Dit', 'https://example.com/audio/thar_dit.mp3', 230, 134000),

  -- Thit Sar (Album 7, Hein Wunna)
  (7, 2, 'Thit Sar', 'https://example.com/audio/thit_sar.mp3', 245, 167000),
  (7, 4, 'Ngar Pho', 'https://example.com/audio/ngar_pho.mp3', 220, 145000),
  (7, 2, 'Ko Kyaw', 'https://example.com/audio/ko_kyaw.mp3', 200, 112000),

  -- Nway Oo (Album 8, Oak Soe Khant)
  (8, 2, 'Nway Oo', 'https://example.com/audio/nway_oo.mp3', 215, 189000),
  (8, 7, 'A Lin Paung', 'https://example.com/audio/a_lin_paung.mp3', 190, 156000),
  (8, 2, 'Pyaw Bpay', 'https://example.com/audio/pyaw_bpay.mp3', 225, 134000),

  -- Ko Htike (Album 9, Yi Wyet)
  (9, 1, 'Ko Htike', 'https://example.com/audio/ko_htike.mp3', 260, 145000),
  (9, 1, 'Kha Ma Yaung', 'https://example.com/audio/kha_ma_yaung.mp3', 235, 112000),
  (9, 8, 'A Yay', 'https://example.com/audio/a_yay.mp3', 210, 89000),

  -- A Chin Taung (Album 10, Reksha)
  (10, 6, 'A Chin Taung', 'https://example.com/audio/a_chin_taung.mp3', 250, 178000),
  (10, 6, 'Mya Nan Kyal', 'https://example.com/audio/mya_nan_kyal.mp3', 220, 156000),
  (10, 7, 'Ta Khaung', 'https://example.com/audio/ta_khaung.mp3', 200, 134000),

  -- Hlaing Bwar (Album 11, Thar Eth)
  (11, 2, 'Hlaing Bwar', 'https://example.com/audio/hlaing_bwar.mp3', 230, 167000),
  (11, 5, 'A Twet Nay', 'https://example.com/audio/a_twet_nay.mp3', 215, 145000),
  (11, 2, 'Ma Pho', 'https://example.com/audio/ma_pho.mp3', 200, 112000),

  -- Memory (Album 12, Nyemak)
  (12, 7, 'Memory', 'https://example.com/audio/memory.mp3', 240, 189000),
  (12, 7, 'Pyan Kwin', 'https://example.com/audio/pyan_kwin.mp3', 210, 156000),
  (12, 4, 'Chit Lan', 'https://example.com/audio/chit_lan.mp3', 225, 134000);

-- ─── Track-Artist Junction ─────────────────
INSERT INTO public.Track_artist_tbl (track_id, artist_id) VALUES
  -- Album 1: Iron Cross
  (1, 1), (2, 1), (3, 1),
  -- Album 2: Beyond The Black
  (4, 2), (5, 2), (6, 2),
  -- Album 3: Sai Sai Kham Leng
  (7, 3), (8, 3), (9, 3),
  -- Album 4: R Zarni
  (10, 4), (11, 4), (12, 4),
  -- Album 5: Phyu Phyu Kyaw Thein
  (13, 5), (14, 5), (15, 5),
  -- Album 6: Hlwan Paing
  (16, 6), (17, 6), (18, 6),
  -- Album 7: Hein Wunna
  (19, 7), (20, 7), (21, 7),
  -- Album 8: Oak Soe Khant
  (22, 8), (23, 8), (24, 8),
  -- Album 9: Yi Wyet
  (25, 9), (26, 9), (27, 9),
  -- Album 10: Reksha
  (28, 10), (29, 10), (30, 10),
  -- Album 11: Thar Eth
  (31, 11), (32, 11), (33, 11),
  -- Album 12: Nyemak
  (34, 12), (35, 12), (36, 12);

-- ─── Done ──────────────────────────────────
-- 8 Genres, 12 Artists, 12 Albums, 36 Tracks
-- All junction tables populated correctly
