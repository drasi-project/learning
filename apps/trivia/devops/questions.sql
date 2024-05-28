--
-- PostgreSQL database dump
--

-- Dumped from database version 11.18
-- Dumped by pg_dump version 16.0

-- Started on 2024-03-08 11:54:27 PST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

--
-- TOC entry 200 (class 1259 OID 24723)
-- Name: Category; Type: TABLE; Schema: public; Owner: drasi
--

CREATE TABLE public."Category" (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    color integer
);


ALTER TABLE public."Category" OWNER TO drasi;

--
-- TOC entry 201 (class 1259 OID 24728)
-- Name: Question; Type: TABLE; Schema: public; Owner: drasi
--

CREATE TABLE public."Question" (
    id integer NOT NULL,
    cat_id integer NOT NULL,
    text character varying(200) NOT NULL,
    answer character varying(200) NOT NULL,
    alt_ans_1 character varying(200) NOT NULL,
    alt_ans_2 character varying(200) NOT NULL,
    alt_ans_3 character varying(200) NOT NULL
);


ALTER TABLE public."Question" OWNER TO drasi;

--
-- TOC entry 4230 (class 0 OID 24723)
-- Dependencies: 200
-- Data for Name: Category; Type: TABLE DATA; Schema: public; Owner: drasi
--

INSERT INTO public."Category" VALUES (1, 'Tech History', 1);
INSERT INTO public."Category" VALUES (2, 'Geography', 2);
INSERT INTO public."Category" VALUES (102, 'Animals', NULL);
INSERT INTO public."Category" VALUES (105, 'History', NULL);
INSERT INTO public."Category" VALUES (106, 'Entertainment: Video Games', NULL);
INSERT INTO public."Category" VALUES (107, 'Entertainment: Film', NULL);
INSERT INTO public."Category" VALUES (108, 'Entertainment: Television', NULL);
INSERT INTO public."Category" VALUES (109, 'Entertainment: Music', NULL);
INSERT INTO public."Category" VALUES (112, 'General Knowledge', NULL);
INSERT INTO public."Category" VALUES (123, 'Science: Gadgets', NULL);
INSERT INTO public."Category" VALUES (125, 'Entertainment: Board Games', NULL);
INSERT INTO public."Category" VALUES (128, 'Vehicles', NULL);
INSERT INTO public."Category" VALUES (143, 'Sports', NULL);
INSERT INTO public."Category" VALUES (147, 'Science: Computers', NULL);
INSERT INTO public."Category" VALUES (205, 'Entertainment: Books', NULL);
INSERT INTO public."Category" VALUES (239, 'Science: Mathematics', NULL);
INSERT INTO public."Category" VALUES (248, 'Entertainment: Comics', NULL);
INSERT INTO public."Category" VALUES (307, 'Entertainment: Musicals &amp; Theatres', NULL);
INSERT INTO public."Category" VALUES (325, 'Mythology', NULL);
INSERT INTO public."Category" VALUES (333, 'Art', NULL);
INSERT INTO public."Category" VALUES (424, 'Celebrities', NULL);
INSERT INTO public."Category" VALUES (436, 'Politics', NULL);
INSERT INTO public."Category" VALUES (122, 'Entertainment: Cartoon & Animations', NULL);
INSERT INTO public."Category" VALUES (104, 'Science & Nature', NULL);
INSERT INTO public."Category" VALUES (101, 'Entertainment', NULL);


--
-- TOC entry 4231 (class 0 OID 24728)
-- Dependencies: 201
-- Data for Name: Question; Type: TABLE DATA; Schema: public; Owner: drasi
--

INSERT INTO public."Question" VALUES (1, 1, 'In what city was Microsoft founded?', 'Albuquerque', 'Seattle', 'Redmond', 'Bellevue');
INSERT INTO public."Question" VALUES (2, 1, 'In what year was Microsoft founded?', '1975', '1978', '1974', '1977');
INSERT INTO public."Question" VALUES (3, 1, 'What was Microsoft''s first hardware product?', 'Z-80 SoftCard', 'Mouse', 'PC', 'TRS-80');
INSERT INTO public."Question" VALUES (4, 1, 'What was Microsoft''s first operating system?', 'Xenix', 'Windows', 'Dos', 'Unix');
INSERT INTO public."Question" VALUES (5, 1, 'What was the code name of Windows 95?', 'Chicago', 'Memphis', 'Nashville', 'Detroit');
INSERT INTO public."Question" VALUES (6, 1, 'What was the code name of Windows XP?', 'Whistler', 'Longhorn', 'Odyssey', 'Neptune');
INSERT INTO public."Question" VALUES (7, 1, 'What was the code name of Azure?', 'Red Dog', 'Singularity', 'Tokyo', 'Zurich');
INSERT INTO public."Question" VALUES (8, 2, 'What is the capital of Canada?', 'Ottawa', 'Toronto', 'Vancouver', 'Montreal');
INSERT INTO public."Question" VALUES (9, 2, 'Where is the southern most point of Africa?', 'Cape Agulhas', 'Cape Point', 'Mossel Baai', 'Cape Town');
INSERT INTO public."Question" VALUES (102, 102, 'What dog breed is one of the oldest breeds of dog and has flourished since before 400 BCE.', 'Pugs', 'Bulldogs', 'Boxers', 'Chihuahua');
INSERT INTO public."Question" VALUES (104, 104, 'What is radiation measured in?', 'Gray ', 'Watt', 'Decibel', 'Kelvin');
INSERT INTO public."Question" VALUES (111, 105, 'Who assassinated Archduke Franz Ferdinand?', 'Gavrilo Princip', 'Nedeljko Čabrinović', 'Oskar Potiorek', 'Ferdinand Cohen-Blind');
INSERT INTO public."Question" VALUES (115, 2, 'What is Laos?', 'Country', 'Region', 'River', 'City');
INSERT INTO public."Question" VALUES (116, 105, 'In which year did the Tokyo Subway Sarin Attack occur?', '1995', '2001', '2011', '1991');
INSERT INTO public."Question" VALUES (118, 105, 'When did the Crisis of the Third Century begin?', '235 AD', '235 BC', '242 AD', '210 AD');
INSERT INTO public."Question" VALUES (112, 112, 'What is the Portuguese word for "Brazil"?', 'Brasil', 'Brazil', 'Brasilia', 'Brasille');
INSERT INTO public."Question" VALUES (124, 102, 'Cashmere is the wool from which kind of animal?', 'Goat', 'Sheep', 'Camel', 'Llama');
INSERT INTO public."Question" VALUES (106, 101, 'How many classes are there in Team Fortress 2?', '9', '10', '8', '7');
INSERT INTO public."Question" VALUES (127, 105, 'Which of the following Assyrian kings did NOT rule during the Neo-Assyrian Empire?', 'Shamshi-Adad III', 'Shalmaneser V', 'Esharhaddon', 'Ashur-nasir-pal II');
INSERT INTO public."Question" VALUES (128, 128, 'The Italian automaker Lamborghini uses what animal as its logo?', 'Bull', 'Bat', 'Horse', 'Snake');
INSERT INTO public."Question" VALUES (109, 101, 'Who is the lead singer of Arctic Monkeys?', 'Alex Turner', 'Jamie Cook', 'Matt Helders', 'Nick O''Malley');
INSERT INTO public."Question" VALUES (119, 101, 'What is the main character of Metal Gear Solid 2?', 'Raiden', 'Solidus Snake', 'Big Boss', 'Venom Snake');
INSERT INTO public."Question" VALUES (137, 101, 'Who is the creator of the Super Smash Bros. Series?', 'Masahiro Sakurai', 'Reggie Fils-Aime', 'Bill Trinen', 'Hideo Kojima');
INSERT INTO public."Question" VALUES (133, 2, 'Which of these is the name of the largest city in the US state Tennessee?', 'Memphis', 'Thebes', 'Alexandria', 'Luxor');
INSERT INTO public."Question" VALUES (134, 128, 'Which animal features on the logo for Abarth, the motorsport division of Fiat?', 'Scorpion', 'Snake', 'Bull', 'Horse');
INSERT INTO public."Question" VALUES (126, 101, 'In what year was the original Sonic the Hedgehog game released?', '1991', '1989', '1993', '1995');
INSERT INTO public."Question" VALUES (121, 101, 'What is the name of JoJo''s Bizarre Adventure Part 5?', 'Vento Aureo', 'Vento Oreo', 'Vanto Aureo', 'Vento Eureo');
INSERT INTO public."Question" VALUES (101, 101, 'In "Hunter x Hunter", which of the following is NOT a type of Nen aura?', 'Restoration', 'Emission', 'Transmutation', 'Specialization');
INSERT INTO public."Question" VALUES (103, 101, 'The two main characters of "No Game No Life", Sora and Shiro, together go by what name?', 'Blank', 'Immanity', 'Disboard', 'Warbeasts');
INSERT INTO public."Question" VALUES (105, 105, 'What was the aim of the "Umbrella Revolution" in Hong Kong in 2014?', 'Genuine universal suffrage', 'Gaining Independence', 'Go back under British Rule', 'Lower taxes');
INSERT INTO public."Question" VALUES (113, 101, 'In 2013, virtual pop-star Hatsune Miku had a sponsorship with which pizza chain?', 'Domino''s', 'Papa John''s', 'Pizza Hut', 'Sabarro''s');
INSERT INTO public."Question" VALUES (132, 101, 'How many spaces are there on a standard Monopoly board?', '40', '28', '55', '36');
INSERT INTO public."Question" VALUES (136, 101, 'Which actor auditioned for the role of Luke Skywalker?', 'Kurt Russell', 'Christopher Lambert', 'Laurence Fishburne', 'James Remar');
INSERT INTO public."Question" VALUES (139, 101, 'What game was used to advertise Steam?', 'Counter-Strike 1.6', 'Half-Life', 'Half-Life 2', 'Team Fortress');
INSERT INTO public."Question" VALUES (141, 101, 'In Kingdom Hearts, how many members does Organization XIII have in total?', '14', '10', '13', '12');
INSERT INTO public."Question" VALUES (107, 101, 'The 1996 film ''Fargo'' is primarily set in which US state?', 'Minnesota', 'North Dakota', 'South Dakota', 'Wisconsin');
INSERT INTO public."Question" VALUES (110, 101, 'Who had a 1976 hit with the song ''You Make Me Feel Like Dancing''?', 'Leo Sayer', 'Elton John', 'Billy Joel', 'Andy Gibb');
INSERT INTO public."Question" VALUES (122, 101, 'What is Scooby-Doo''s real name?', 'Scoobert', 'Scooter', 'Scrappy', 'Shooby');
INSERT INTO public."Question" VALUES (135, 101, 'Who had a 1983 hit with the song ''Africa''?', 'Toto', 'Foreigner', 'Steely Dan', 'Journey');
INSERT INTO public."Question" VALUES (108, 101, 'The theme for the popular science fiction series "Doctor Who" was composed by who?', 'Ron Grainer', 'Murray Gold', 'Delia Derbyshire', 'Peter Howell');
INSERT INTO public."Question" VALUES (143, 143, 'Which NBA player has the most games played over the course of their career?', 'Robert Parish', 'Kareem Abdul-Jabbar', 'Kevin Garnett', 'Kobe Bryant');
INSERT INTO public."Question" VALUES (146, 112, 'According to the 2014-2015 Australian Bureau of Statistics, what percentage of Australians were born overseas?', '28%', '13%', '20%', '7%');
INSERT INTO public."Question" VALUES (147, 147, 'What does the International System of Quantities refer 1024 bytes as?', 'Kibibyte', 'Kylobyte', 'Kilobyte', 'Kelobyte');
INSERT INTO public."Question" VALUES (221, 112, 'Which best selling toy of 1983 caused hysteria, resulting in riots breaking out in stores?', 'Cabbage Patch Kids', 'Transformers', 'Care Bears', 'Rubiks Cube');
INSERT INTO public."Question" VALUES (150, 104, 'What polymer is used to make CDs, safety goggles and riot shields?', 'Polycarbonate', 'Rubber', 'Nylon', 'Bakelite');
INSERT INTO public."Question" VALUES (114, 101, 'In the video game "League of Legends" which character is known as "The Sinister Blade"?', 'Katarina', 'Shaco', 'Akali', 'Zed');
INSERT INTO public."Question" VALUES (140, 101, 'What was the #1 selling game on Steam by revenue in 2016?', 'Sid Meier''s Civilization VI', 'Grand Theft Auto V', 'Counter Strike: Global Offensive', 'Dark Souls III');
INSERT INTO public."Question" VALUES (203, 112, 'Whose greyscale face is on the kappa emoticon on Twitch?', 'Josh DeSeno', 'Justin DeSeno', 'John DeSeno', 'Jimmy DeSeno');
INSERT INTO public."Question" VALUES (204, 101, 'Which studio animated Afro Samurai?', 'Gonzo', 'Kyoto Animation', 'xebec', 'Production I.G');
INSERT INTO public."Question" VALUES (206, 104, 'Which of these is a stop codon in DNA?', 'TAA', 'ACT', 'ACA', 'GTA');
INSERT INTO public."Question" VALUES (142, 101, 'What TV show is about a grandfather dragging his grandson around on adventures?', 'Rick & Morty', 'Family Guy', 'South Park', 'American Dad');
INSERT INTO public."Question" VALUES (209, 2, 'Where are the Nazca Lines located?', 'Peru', 'Brazil', 'Colombia', 'Ecuador');
INSERT INTO public."Question" VALUES (211, 104, 'What lies at the center of our galaxy?', 'A black hole', 'A wormhole', 'A supernova', 'A quasar');
INSERT INTO public."Question" VALUES (212, 112, 'What is the name of the Jewish New Year?', 'Rosh Hashanah', 'Elul', 'New Year', 'Succoss');
INSERT INTO public."Question" VALUES (214, 112, 'What is the nickname of the US state of California?', 'Golden State', 'Sunshine State', 'Bay State', 'Treasure State');
INSERT INTO public."Question" VALUES (215, 2, 'What is the capital of Jamaica?', 'Kingston', 'San Juan', 'Port-au-Prince', 'Bridgetown');
INSERT INTO public."Question" VALUES (216, 2, 'Which of these is NOT a province in China?', 'Yangtze', 'Fujian', 'Sichuan', 'Guangdong');
INSERT INTO public."Question" VALUES (217, 2, 'What is the capital city of New Zealand?', 'Wellington', 'Auckland', 'Christchurch', 'Melbourne');
INSERT INTO public."Question" VALUES (219, 112, 'Earl Grey tea is black tea flavoured with what?', 'Bergamot oil', 'Lavender', 'Vanilla', 'Honey');
INSERT INTO public."Question" VALUES (220, 105, 'What is the name of the ship which was only a few miles away from the RMS Titanic when it struck an iceberg on April 14, 1912?', 'Californian', 'Carpathia', 'Cristol', 'Commerce');
INSERT INTO public."Question" VALUES (225, 128, 'The LS1 engine is how many cubic inches?', '346', '350', '355', '360');
INSERT INTO public."Question" VALUES (218, 101, 'In the 2010 Nightmare on Elm Street reboot, who played Freddy Kruger?', 'Jackie Earle Haley', 'Tyler Mane', 'Derek Mears', 'Gunnar Hansen');
INSERT INTO public."Question" VALUES (227, 101, 'Which of these is not a single by Pink Floyd guitarist, David Gilmour?', 'Sunset Strip', 'Rattle That Lock', 'Blue Light', 'Arnold Layne');
INSERT INTO public."Question" VALUES (229, 105, 'How many times was Albert Einstein married in his lifetime?', 'Twice', 'Five', 'Thrice', 'Once');
INSERT INTO public."Question" VALUES (235, 101, 'Which of these bands is the oldest?', 'Pink Floyd', 'AC/DC', 'Metallica', 'Red Hot Chili Peppers');
INSERT INTO public."Question" VALUES (231, 104, 'To the nearest minute, how long does it take for light to travel from the Sun to the Earth?', '8 Minutes', '6 Minutes', '2 Minutes', '12 Minutes');
INSERT INTO public."Question" VALUES (233, 143, 'In Formula 1, the Virtual Safety Car was introduced following the fatal crash of which driver?', 'Jules Bianchi', 'Ayrton Senna', 'Ronald Ratzenberger', 'Gilles Villeneuve');
INSERT INTO public."Question" VALUES (144, 101, 'Who voices the character "Vernon Cherry" in "Red Dead Redemption"?', 'Casey Mongillo', 'Tara Strong', 'Troy Baker', 'Rob Wiethoff');
INSERT INTO public."Question" VALUES (145, 101, 'Cryoshell, known for "Creeping in My Soul" did the advertising music for what Lego Theme?', 'Bionicle', 'Hero Factory', 'Ben 10 Alien Force', 'Star Wars');
INSERT INTO public."Question" VALUES (148, 101, 'How many times do you fight Gilgamesh in "Final Fantasy 5"?', '6', '4', '5', '3');
INSERT INTO public."Question" VALUES (239, 239, 'What Greek letter is used to signify summation?', 'Sigma', 'Delta', 'Alpha', 'Omega');
INSERT INTO public."Question" VALUES (240, 105, 'What year did World War I begin?', '1914', '1905', '1919', '1925');
INSERT INTO public."Question" VALUES (241, 112, 'What does VR stand for?', 'Virtual Reality', 'Very Real', 'Visual Recognition', 'Voice Recognition');
INSERT INTO public."Question" VALUES (202, 101, 'In the 1979 British film "Quadrophenia" what is the name of the seaside city the mods are visiting?', 'Brighton', 'Eastbourne', 'Mousehole', 'Bridlington');
INSERT INTO public."Question" VALUES (243, 147, 'On which computer hardware device is the BIOS chip located?', 'Motherboard', 'Hard Disk Drive', 'Central Processing Unit', 'Graphics Processing Unit');
INSERT INTO public."Question" VALUES (205, 101, 'In the book series "Odd Thomas", Danny Jessup has what genetic disease? ', ' Osteogenesis Imperfecta', 'Spinocerebellar ataxia', 'Adrenoleukodystrophy', 'Cystic Fibrosis');
INSERT INTO public."Question" VALUES (207, 101, 'What is the name of the main character of the anime "One-Punch Man"?', 'Saitama', 'Genos', 'Sonic', 'King');
INSERT INTO public."Question" VALUES (210, 112, 'The Mexican Beer "Corona" is what type of beer?', 'Pale Lager', 'India Pale Ale', 'Pilfsner', 'Baltic Porter');
INSERT INTO public."Question" VALUES (224, 101, 'Medaka Kurokami from "Medaka Box" has what abnormality?', 'The End', 'Perfection', 'Sandbox', 'Fairness');
INSERT INTO public."Question" VALUES (213, 101, 'What is the name of the world that the MMO "RuneScape" takes place in?', 'Gielinor', 'Glindor', 'Azeroth', 'Zaros');
INSERT INTO public."Question" VALUES (232, 112, 'In the MMO RPG "Realm of the Mad God", what dungeon is widely considered to be the most difficult?', 'The Shatter''s', 'Snake Pit', 'The Tomb of the Acient''s', 'The Puppet Master''s Theater');
INSERT INTO public."Question" VALUES (223, 101, 'Which monster in "Monster Hunter Tri" was causing earthquakes in Moga Village?', 'Ceadeus', 'Alatreon', 'Rathalos', 'Lagiacrus');
INSERT INTO public."Question" VALUES (247, 147, 'What is the number of keys on a standard Windows Keyboard?', '104', '64', '94', '76');
INSERT INTO public."Question" VALUES (302, 101, 'Which of these anime have over 7,500 episodes?', 'Sazae-san', 'Naruto', 'One Piece', 'Chibi Maruko-chan');
INSERT INTO public."Question" VALUES (305, 102, 'What is the scientific name of the cheetah?', 'Acinonyx jubatus', 'Panthera onca', 'Lynx rufus', 'Felis catus');
INSERT INTO public."Question" VALUES (337, 333, 'Which Van Gogh painting depicts the view from his asylum in Saint-Remy-de-Provence in southern France?', 'The Starry Night', 'Wheatfields with Crows', 'The Sower with Setting Sun', 'The Church at Auvers');
INSERT INTO public."Question" VALUES (310, 147, 'What does the acronym CDN stand for in terms of networking?', 'Content Delivery Network', 'Content Distribution Network', 'Computational Data Network', 'Compressed Data Network');
INSERT INTO public."Question" VALUES (311, 104, 'How long is a light-year?', '9.461 Trillion Kilometres', '1 AU', '105.40 Earth-years', '501.2 Million Miles');
INSERT INTO public."Question" VALUES (313, 112, 'What was Bank of America originally established as?', 'Bank of Italy', 'Bank of Long Island', 'Bank of Pennsylvania', 'Bank of Charlotte');
INSERT INTO public."Question" VALUES (314, 105, 'The coat of arms of the King of Spain contains the arms from the monarchs of Castille, Leon, Aragon and which other former Iberian kingdom?', 'Navarre', 'Galicia', 'Granada', 'Catalonia');
INSERT INTO public."Question" VALUES (316, 2, 'Which state of the United States is the smallest?', 'Rhode Island ', 'Maine', 'Vermont', 'Massachusetts');
INSERT INTO public."Question" VALUES (318, 102, 'What is the collective noun for vultures?', 'Wake', 'Ambush', 'Building', 'Gaze');
INSERT INTO public."Question" VALUES (320, 128, 'What year did the Chevrolet LUV mini truck make its debut?', '1972', '1982', '1975', '1973');
INSERT INTO public."Question" VALUES (236, 101, 'What is the default name of the Vampire character in "Shining Soul 2".', 'Bloodstar', 'Sachs', 'Dracuul', 'Alucard');
INSERT INTO public."Question" VALUES (325, 325, 'The Maori hold that which island nation was founded by Kupe, who discovered it under a long white cloud?', 'New Zealand', 'Vanuatu', 'Fiji', 'Hawaii');
INSERT INTO public."Question" VALUES (327, 112, 'Which product did Nokia, the telecommunications company, originally sell?', 'Paper', 'Phones', 'Computers', 'Processors');
INSERT INTO public."Question" VALUES (329, 2, 'The World Health Organization headquarters is located in which European country?', 'Switzerland', 'United Kingdom', 'France', 'Belgium');
INSERT INTO public."Question" VALUES (330, 112, 'What are the three starter Pokemon available in Pokemon Black and White?', 'Snivy, Tepig, Oshawott', 'Snivy, Fennekin, Froakie', 'Chespin, Tepig, Froakie', 'Chespin, Fennekin, Oshawott');
INSERT INTO public."Question" VALUES (245, 101, 'Which of the following Pokemon Types was present in the original games, Red and Blue?', 'Ice', 'Steel', 'Dark', 'Fairy');
INSERT INTO public."Question" VALUES (248, 101, 'Which one of these superhero teams appears in the Invincible comics?', 'Guardians of the Globe', 'Avengers', 'Justice League', 'Teenage Mutant Ninja Turtles');
INSERT INTO public."Question" VALUES (249, 101, 'Which drive form was added into Kingdom Hearts II Final Mix?', 'Limit Form', 'Valor Form', 'Wisdom Form', 'Anti Form');
INSERT INTO public."Question" VALUES (250, 101, 'What book series published by Jim Butcher follows a wizard in modern day Chicago?', 'The Dresden Files', 'A Hat in Time', 'The Cinder Spires', 'My Life as a Teenage Wizard');
INSERT INTO public."Question" VALUES (335, 105, 'What was the real name of the Albanian national leader Skanderbeg?', 'Gjergj Kastrioti', 'Diturak Zhulati', 'Iskander Bejko', 'Mirash Krasniki');
INSERT INTO public."Question" VALUES (301, 101, 'Which of the following Call of Duty games was a PS3 launch title?', 'Call of Duty 3', 'Call of Duty 4: Modern Warfare', 'Call of Duty: World at War', 'Call of Duty: Roads to Victory');
INSERT INTO public."Question" VALUES (339, 105, 'Which of the following is not in the Indo-European language family?', 'Finnish', 'English', 'Hindi', 'Russian');
INSERT INTO public."Question" VALUES (343, 2, 'Which country is the home of the largest Japanese population outside of Japan?', 'Brazil', 'China', 'Russia', 'The United States');
INSERT INTO public."Question" VALUES (317, 101, 'What was the first interactive movie video game?', 'Astron Belt', 'Dragon''s Lair', 'Cube Quest', 'M.A.C.H. 3');
INSERT INTO public."Question" VALUES (326, 102, 'For what reason would a spotted hyena "laugh"?', 'Nervousness', 'Excitement', 'Aggression', 'Exhaustion');
INSERT INTO public."Question" VALUES (308, 112, 'In which fast food chain can you order a Jamocha Shake?', 'Arby''s', 'McDonald''s', 'Burger King', 'Wendy''s');
INSERT INTO public."Question" VALUES (304, 101, 'What is the lowest amount of max health you can have in Team Fortress 2?', '70', '100', '50', '95');
INSERT INTO public."Question" VALUES (306, 101, 'Which puzzle game was designed by a Russian programmer, featuring Russian buildings and music?', 'Tetris', 'Jenga', 'Boulder Dash', 'Puzzled');
INSERT INTO public."Question" VALUES (319, 101, 'In the Friday The 13th series, what year did Jason drown in?', '1957', '1955', '1953', '1959');
INSERT INTO public."Question" VALUES (348, 147, 'Which of these Cherry MX mechanical keyboard switches is both tactile and clicky?', 'Cherry MX Blue', 'Cherry MX Black', 'Cherry MX Red', 'Cherry MX Brown');
INSERT INTO public."Question" VALUES (349, 112, 'When someone is inexperienced they are said to be what color?', 'Green', 'Red', 'Blue', 'Yellow');
INSERT INTO public."Question" VALUES (344, 101, 'The voice actor for which Portal 2 character was not a TV or film actor prior to the game?', 'GLaDOS', 'Cave Johnson', 'Wheatley', 'Atlas / P-Body');
INSERT INTO public."Question" VALUES (402, 128, 'What country was the Trabant 601 manufactured in?', 'East Germany', 'Soviet Union', 'Hungary', 'France');
INSERT INTO public."Question" VALUES (403, 2, 'On a London Underground map, what colour is the Circle Line?', 'Yellow', 'Red', 'Blue', 'Green');
INSERT INTO public."Question" VALUES (346, 101, 'Johnny Cash did a cover of this song written by lead singer of Nine Inch Nails, Trent Reznor.', 'Hurt', 'Closer', 'A Warm Place', 'Big Man with a Gun');
INSERT INTO public."Question" VALUES (405, 2, 'What is the official national language of Pakistan?', 'Urdu', 'Indian', 'Punjabi', 'Pashto');
INSERT INTO public."Question" VALUES (407, 101, 'Which of these characters is the mascot of the video game company SEGA?', 'Sonic the Hedgehog', 'Dynamite Headdy', 'Alex Kidd', 'Opa-Opa');
INSERT INTO public."Question" VALUES (409, 105, 'In what year was the video game company Electronic Arts founded?', '1982', '1999', '1981', '2005');
INSERT INTO public."Question" VALUES (413, 143, 'Which player holds the NHL record of 2,857 points?', 'Wayne Gretzky', 'Mario Lemieux ', 'Sidney Crosby', 'Gordie Howe');
INSERT INTO public."Question" VALUES (414, 147, 'In the server hosting industry IaaS stands for...', 'Infrastructure as a Service', 'Internet as a Service', 'Internet and a Server', 'Infrastructure as a Server');
INSERT INTO public."Question" VALUES (410, 101, 'Which country is singer Kyary Pamyu Pamyu from?', 'Japan', 'South Korea', 'China', 'Vietnam');
INSERT INTO public."Question" VALUES (418, 2, 'Which country is the Taedong River in?', 'North Korea', 'South Korea', 'Japan', 'China');
INSERT INTO public."Question" VALUES (421, 2, 'What city  has the busiest airport in the world?', 'Atlanta, Georgia USA', 'London, England', 'Chicago,Illinois ISA', 'Tokyo,Japan');
INSERT INTO public."Question" VALUES (411, 2, 'What is the northernmost human settlement with year round inhabitants?', 'Alert, Canada', 'Nagurskoye, Russia', 'McMurdo Station, Antarctica ', 'Honningsvag, Norway');
INSERT INTO public."Question" VALUES (307, 101, 'Which of these musicals won the Tony Award for Best Musical?', 'Rent', 'The Color Purple', 'American Idiot', 'Newsies');
INSERT INTO public."Question" VALUES (342, 101, 'In 2008, British celebrity chef Gordon Ramsay believes he almost died after suffering what accident in Iceland while filming?', 'Slipping off a cliff, and nearly drowning in icy water', 'Crash landing when arriving at Keflavik airport', 'A minor car accident in a snowstorm', 'Being served under-cooked chicken at his hotel');
INSERT INTO public."Question" VALUES (321, 101, 'Pink Floyd made this song for their previous lead singer Syd Barrett.', 'Shine On You Crazy Diamond', 'Wish You Were Here', 'Have A Cigar', 'Welcome to the Machine');
INSERT INTO public."Question" VALUES (323, 101, 'What is the sum of all the tiles in a standard box of Scrabble?', '187', '207', '197', '177');
INSERT INTO public."Question" VALUES (434, 123, 'Which round does a WW2 M1 Garand fire?', '.30-06', '.308', '7.62', '7.62x51mm');
INSERT INTO public."Question" VALUES (436, 436, 'Which of the following Pacific Islander countries is ruled by a constitutional monarchy?', 'Tonga', 'Palau', 'Fiji', 'Kiribati');
INSERT INTO public."Question" VALUES (438, 105, 'What was William Frederick Cody better known as?', 'Buffalo Bill', 'Billy the Kid', 'Wild Bill Hickok', 'Pawnee Bill');
INSERT INTO public."Question" VALUES (444, 101, 'Who is the main character with yellow hair in the anime Naruto?', 'Naruto', 'Ten Ten', 'Sasuke', 'Kakashi');
INSERT INTO public."Question" VALUES (345, 112, 'What is the profession of Elon Musk''s mom, Maye Musk?', 'Model', 'Professor', 'Biologist', 'Musician');
INSERT INTO public."Question" VALUES (419, 112, 'What is a "dakimakura"?', 'A body pillow', 'A Chinese meal, essentially composed of fish', 'A yoga posture', 'A word used to describe two people who truly love each other');
INSERT INTO public."Question" VALUES (424, 424, 'Which TV chef wrote an autobiography titled "Humble Pie"?', 'Gordon Ramsay', 'Jamie Oliver', 'Ainsley Harriott', 'Antony Worrall Thompson');
INSERT INTO public."Question" VALUES (432, 101, 'Who is the creator of the manga series "One Piece"?', 'Eiichiro Oda', 'Yoshihiro Togashi', 'Hayao Miyazaki', 'Masashi Kishimoto');
INSERT INTO public."Question" VALUES (548, 112, 'What does the "G" mean in "G-Man"?', 'Government', 'Going', 'Ghost', 'Geronimo');
INSERT INTO public."Question" VALUES (416, 101, 'In the Lord of the Rings, who is the father of the dwarf Gimli?', 'Gloin', 'Thorin Oakenshield', 'Bombur', 'Dwalin');
INSERT INTO public."Question" VALUES (412, 101, 'Which of the following Pokemon games released first?', 'Pokemon Crystal', 'Pokemon Platinum', 'Pokemon FireRed', 'Pokemon Black');
INSERT INTO public."Question" VALUES (422, 101, 'What war is Call Of Duty: Black Ops based on?', 'Cold War', 'WW3', 'Vietnam', 'WW1');
INSERT INTO public."Question" VALUES (542, 105, 'The minigun was designed in 1960 by which manufacturer.', 'General Electric', 'Colt Firearms', 'Heckler & Koch', 'Sig Sauer');
INSERT INTO public."Question" VALUES (450, 104, 'Deionized water is water with which of the following removed?', 'Iron', 'Oxygen', 'Hydrogen', 'Uncharged atoms');
INSERT INTO public."Question" VALUES (328, 101, 'Liam Howlett founded which electronic music group in 1990?', 'The Prodigy', 'The Chemical Brothers', 'The Crystal Method', 'Infected Mushroom');
INSERT INTO public."Question" VALUES (508, 2, 'What is the most populous Muslim-majority nation in 2010?', 'Indonesia', 'Saudi Arabia', 'Iran', 'Sudan');
INSERT INTO public."Question" VALUES (511, 105, 'How old was Lyndon B. Johnson when he assumed the role of President of the United States?', '55', '50', '60', '54');
INSERT INTO public."Question" VALUES (512, 147, 'What major programming language does Unreal Engine 4 use?', 'C++', 'Assembly', 'C#', 'ECMAScript');
INSERT INTO public."Question" VALUES (516, 2, 'Which of these island countries is located in the Caribbean?', 'Barbados', 'Fiji', 'Maldives', 'Seychelles');
INSERT INTO public."Question" VALUES (519, 105, 'During the Roman Triumvirate of 42 BCE, what region of the Roman Republic was given to Lepidus?', 'Hispania ', 'Italia', 'Gallia', 'Asia');
INSERT INTO public."Question" VALUES (338, 101, 'Which of these is NOT a playable character in the 2016 video game Overwatch?', 'Invoker', 'Mercy', 'Winston', 'Zenyatta');
INSERT INTO public."Question" VALUES (522, 104, 'What was the first organic compound to be synthesized from inorganic compounds?', 'Urea', 'Propane', 'Ethanol', 'Formaldehyde');
INSERT INTO public."Question" VALUES (340, 101, 'In Cook, Serve, Delicious!, which food is NOT included in the game?', 'Pie', 'Shish Kabob', 'Hamburger', 'Lasagna');
INSERT INTO public."Question" VALUES (341, 101, 'What was the code name given to Sonic the Hedgehog 4 during its development?', 'Project Needlemouse', 'Project Bluespike', 'Project Roboegg', 'Project Darksphere');
INSERT INTO public."Question" VALUES (246, 101, 'What was the development code name for the "Weatherlight" expansion for "Magic: The Gathering", released in 1997?', 'Mocha Latte', 'Decaf', 'Frappuccino', 'Macchiato');
INSERT INTO public."Question" VALUES (529, 2, 'What are the four corner states of the US?', 'Utah, Colorado, Arizona, New Mexico', 'Oregon, Idaho, Nevada, Utah', 'Kansas, Oklahoma, Arkansas, Louisiana', 'South Dakota, Minnesota, Nebraska, Iowa');
INSERT INTO public."Question" VALUES (534, 147, 'Dutch computer scientist Mark Overmars is known for creating which game development engine?', 'Game Maker', 'Stencyl', 'Construct', 'Torque 2D');
INSERT INTO public."Question" VALUES (324, 101, 'Who was the mascot of SEGA before "Sonic the Hedgehog"?', 'Alex Kidd', 'Opa Opa', 'NiGHTS', 'Ristar');
INSERT INTO public."Question" VALUES (315, 101, 'What date is referenced in the 1971 song "September" by Earth, Wind & Fire?', '21st of September', '26th of September', '23rd of September', '24th of September');
INSERT INTO public."Question" VALUES (426, 101, 'Which of these characters was considered, but ultimately not included, for Super Smash Bros. Melee?', 'James Bond', 'Diddy Kong', 'Mega Man', 'Wave Racer');
INSERT INTO public."Question" VALUES (429, 101, 'In World of Warcraft the default UI color that signifies Druid is what?', 'Orange', 'Brown', 'Green', 'Blue');
INSERT INTO public."Question" VALUES (430, 101, 'Which Mario spin-off game did Waluigi make his debut?', 'Mario Tennis', 'Mario Party 3', 'Mario Kart: Double Dash!!', 'Mario Golf: Toadstool Tour');
INSERT INTO public."Question" VALUES (440, 101, 'In what engine was Titanfall made in?', 'Source Engine', 'Frostbite 3', 'Unreal Engine', 'Cryengine');
INSERT INTO public."Question" VALUES (441, 101, 'Carcassonne is based on which French town?', 'Carcassonne', 'Paris', 'Marseille', 'Clermont-Ferrand');
INSERT INTO public."Question" VALUES (442, 101, 'Which of these songs by Skrillex features Fatman Scoop as a side artist?', 'Recess', 'All is Fair in Love and Brostep', 'Rock N Roll (Will Take You to the Mountain)', 'Scary Monsters and Nice Sprites');
INSERT INTO public."Question" VALUES (447, 101, 'What was the name of the hip hop group Kanye West was a member of in the late 90s?', 'The Go-Getters', 'The Jumpers', 'The Kickstarters', 'The Beat-Busters');
INSERT INTO public."Question" VALUES (507, 112, 'What does the Latin phrase "Veni, vidi, vici" translate into English?', 'I came, I saw, I conquered', 'See no evil, hear no evil, speak no evil', 'Life, liberty, and happiness', 'Past, present, and future');
INSERT INTO public."Question" VALUES (514, 101, 'In "A Certain Scientific Railgun", how many "sisters" did Accelerator have to kill to achieve the rumored level 6?', '20,000', '128', '10,000', '5,000');
INSERT INTO public."Question" VALUES (532, 101, 'What is the name of the device that allows for infinite energy in the anime "Dimension W"?', 'Coils', 'Wires', 'Collectors', 'Tesla');
INSERT INTO public."Question" VALUES (533, 436, 'The 2014 movie "The Raid 2: Berandal" was mainly filmed in which Asian country?', 'Indonesia', 'Thailand', 'Brunei', 'Malaysia');
INSERT INTO public."Question" VALUES (509, 112, 'Which one of these Swedish companies was founded in 1943?', 'IKEA', 'H & M', 'Lindex', 'Clas Ohlson');
INSERT INTO public."Question" VALUES (443, 101, 'In the game Half-Life, which enemy is showcased as the final boss?', 'The Nihilanth', 'Dr. Wallace Breen', 'G-Man', 'The Gonarch');
INSERT INTO public."Question" VALUES (445, 101, 'In Need For Speed Most Wanted (2005), what do you drive at the beginning of the career mode?', 'BMW M3 GTR', 'Porsche 911 Turbo', 'Nissan 240SX', 'Ford Mustang');
INSERT INTO public."Question" VALUES (449, 101, 'Which album was released by Kanye West in 2013?', 'Yeezus', 'My Beautiful Dark Twisted Fantasy', 'The Life of Pablo', 'Watch the Throne');
INSERT INTO public."Question" VALUES (630, 147, 'The computer OEM manufacturer Clevo, known for its Sager notebook line, is based in which country?', 'Taiwan', 'United States', 'Germany', 'China (People''s Republic of)');
INSERT INTO public."Question" VALUES (602, 424, 'Gabe Newell was born in which year?', '1962 ', '1970', '1960', '1972');
INSERT INTO public."Question" VALUES (603, 105, 'After the 1516 Battle of Marj Dabiq, the Ottoman Empire took control of Jerusalem from which sultanate?', 'Mamluk', 'Ayyubid', 'Ummayyad', 'Seljuq');
INSERT INTO public."Question" VALUES (606, 105, 'Who was the first man to travel into outer space twice?', 'Gus Grissom', 'Vladimir Komarov', 'Charles Conrad', 'Yuri Gagarin');
INSERT INTO public."Question" VALUES (607, 105, 'In the War of the Pacific (1879 - 1883), Bolivia lost its access to the Pacific Ocean after being defeated by which South American country?', 'Chile', 'Peru', 'Brazil', 'Argentina');
INSERT INTO public."Question" VALUES (612, 333, 'Who painted the Mona Lisa?', 'Leonardo da Vinci ', 'Pablo Picasso', ' Vincent van Gogh', 'Michelangelo');
INSERT INTO public."Question" VALUES (631, 143, 'Which NBA player won Most Valuable Player for the 1999-2000 season?', 'Shaquille O''Neal', 'Allen Iverson', 'Kobe Bryant', 'Paul Pierce');
INSERT INTO public."Question" VALUES (639, 143, 'Which soccer team won the Copa America Centenario 2016?', 'Chile', 'Argentina', 'Brazil', 'Colombia');
INSERT INTO public."Question" VALUES (627, 112, 'This field is sometimes known as "The Dismal Science."', 'Economics', 'Philosophy', 'Politics', 'Physics');
INSERT INTO public."Question" VALUES (347, 101, 'Who played Deputy Marshal Samuel Gerard in the 1993 film "The Fugitive"?', 'Tommy Lee Jones', 'Harrison Ford', 'Harvey Keitel', 'Martin Landau');
INSERT INTO public."Question" VALUES (401, 101, 'In "Call Of Duty: Zombies", what is the name of the machine that upgrades weapons?', 'Pack-A-Punch', 'Wunderfizz', 'Gersch Device', 'Mule Kick');
INSERT INTO public."Question" VALUES (415, 101, 'This movie contains the quote, "Houston, we have a problem."', 'Apollo 13', 'The Right Stuff', 'Capricorn One', 'Marooned');
INSERT INTO public."Question" VALUES (431, 101, 'Whose albums included "Back in Black" and "Ballbreaker"?', 'AC/DC', 'Iron Maiden', 'Black Sabbath', 'Metallica');
INSERT INTO public."Question" VALUES (623, 104, 'What was the first living creature in space?', 'Fruit Flies ', 'Monkey', 'Dog', 'Mouse');
INSERT INTO public."Question" VALUES (435, 101, 'In "PAYDAY 2", what weapon has the highest base weapon damage on a per-shot basis?', 'HRL-7', 'Heavy Crossbow', 'Thanatos .50 cal', 'Broomstick Pistol');
INSERT INTO public."Question" VALUES (625, 143, 'Why was The Green Monster at Fenway Park was originally built?', 'To prevent viewing games from outside the park.', 'To make getting home runs harder.', 'To display advertisements.', 'To provide extra seating.');
INSERT INTO public."Question" VALUES (439, 101, 'What is the name of the currency in the "Animal Crossing" series?', 'Bells', 'Sea Shells', 'Leaves', 'Bugs');
INSERT INTO public."Question" VALUES (632, 105, 'When did Norway become free from Sweden?', '1905', '1925', '1814', '1834');
INSERT INTO public."Question" VALUES (633, 325, 'Which of the following is NOT a god in Norse Mythology.', 'Jens', 'Loki', 'Tyr', 'Snotra');
INSERT INTO public."Question" VALUES (506, 101, 'In the "Halo" series, what is the name of the race of aliens humans refer to as "Grunts"?', 'Unggoy', 'Huragok', 'Sangheili', 'Yanme''e');
INSERT INTO public."Question" VALUES (635, 325, 'The ancient Roman god of war was commonly known as which of the following?', 'Mars', 'Jupiter', 'Juno', 'Ares');
INSERT INTO public."Question" VALUES (636, 105, 'What was the bloodiest single-day battle during the American Civil War?', 'The Battle of Antietam', 'The Siege of Vicksburg', 'The Battle of Gettysburg', 'The Battles of Chancellorsville');
INSERT INTO public."Question" VALUES (504, 101, 'Where are Terror Fiends more commonly found in the Nintendo game Miitopia?', 'New Lumos', 'Peculia', 'The Sky Scraper', 'Otherworld');
INSERT INTO public."Question" VALUES (513, 101, 'Without enchantments, which pickaxe in minecraft mines blocks the quickest.', 'Golden ', 'Diamond', 'Iron', 'Obsidian');
INSERT INTO public."Question" VALUES (518, 101, 'In the game Warframe, what Mastery Rank do you need to have to build the Tigris Prime?', '13', '6', '18', '10');
INSERT INTO public."Question" VALUES (644, 105, 'In 1961, an American B-52 aircraft crashed and nearly detonated two 4mt nuclear bombs over which US city?', 'Goldsboro, North Carolina', 'Hicksville, New York', 'Jacksonville, Florida', 'Conway, Arkansas');
INSERT INTO public."Question" VALUES (520, 101, 'Leonardo Di Caprio won his first Best Actor Oscar for his performance in which film?', 'The Revenant', 'The Wolf Of Wall Street', 'Shutter Island', 'Inception');
INSERT INTO public."Question" VALUES (601, 101, 'Which of the following is not a character in the video game Doki Doki Literature Club?', 'Nico', 'Monika', 'Natsuki', 'Sayori');
INSERT INTO public."Question" VALUES (649, 112, 'The likeness of which president is featured on the rare $2 bill of USA currency?', 'Thomas Jefferson', 'Martin Van Buren', 'Ulysses Grant', 'John Quincy Adams');
INSERT INTO public."Question" VALUES (549, 112, 'What is the romanized Japanese word for "university"?', 'Daigaku', 'Toshokan', 'Jimusho', 'Shokudou');
INSERT INTO public."Question" VALUES (611, 101, 'The "To Love-Ru" Manga was started in what year?', '2006', '2007', '2004', '2005');
INSERT INTO public."Question" VALUES (608, 101, 'In Back to the Future Part II, Marty and Dr. Emmett Brown go to which future date?', 'October 21, 2015', 'August 28, 2015', 'July 20, 2015', 'January 25, 2015');
INSERT INTO public."Question" VALUES (622, 101, 'Which of these games was the earliest known first-person shooter with a known time of publication?', 'Spasim', 'Doom', 'Wolfenstein', 'Quake');
INSERT INTO public."Question" VALUES (626, 101, 'Which band is the longest active band in the world with no breaks or line-up changes?', 'U2', 'Radiohead', 'Rush', 'Rolling Stones');
INSERT INTO public."Question" VALUES (610, 101, 'In what year was "Super Mario Sunshine" released?', '2002', '2003', '2000', '2004');
INSERT INTO public."Question" VALUES (710, 104, 'How many types of quarks are there in the standard model of physics?', '6', '2', '3', '4');
INSERT INTO public."Question" VALUES (711, 112, 'A statue of Charles Darwin sits in what London museum?', 'Natural History Museum', 'Tate', 'British Museum', 'Science Museum');
INSERT INTO public."Question" VALUES (712, 2, 'The Pyrenees mountains are located on the border of which two countries?', 'France and Spain', 'Italy and Switzerland', 'Norway and Sweden', 'Russia and Ukraine');
INSERT INTO public."Question" VALUES (716, 105, 'Who was the only US President to be elected four times?', 'Franklin Roosevelt', 'Theodore Roosevelt', 'George Washington', 'Abraham Lincoln');
INSERT INTO public."Question" VALUES (715, 112, 'The word "abulia" means which of the following?', 'The inability to make decisions', 'The inability to stand up', 'The inability to concentrate on anything', 'A feverish desire to rip one''s clothes off');
INSERT INTO public."Question" VALUES (722, 112, 'Which country drives on the left side of the road?', 'Japan', 'Germany', 'Russia', 'China');
INSERT INTO public."Question" VALUES (723, 105, 'In what prison was Adolf Hitler held in 1924?', 'Landsberg Prison', 'Spandau Prison', 'Ebrach Abbey', 'Hohenasperg');
INSERT INTO public."Question" VALUES (524, 101, 'In the game Nuclear Throne, what organization chases the player character throughout the game?', 'The I.D.P.D', 'The Fishmen', 'The Bandits', 'The Y.V.G.G');
INSERT INTO public."Question" VALUES (725, 105, 'During which American Civil War campaign did Union troops dig a tunnel beneath Confederate troops to detonate explosives underneath them?', 'Siege of Petersburg', 'Siege of Vicksburg', 'Antietam Campaign', 'Gettysburg Campagin');
INSERT INTO public."Question" VALUES (530, 101, 'In World of Warcraft lore, who organized the creation of the Paladins?', 'Alonsus Faol', 'Uther the Lightbringer', 'Alexandros Mograine', 'Sargeras, The Daemon Lord');
INSERT INTO public."Question" VALUES (729, 105, 'In what year was the famous 45 foot tall Hollywood sign first erected?', '1923', '1903', '1913', '1933');
INSERT INTO public."Question" VALUES (537, 101, 'In WarioWare: Smooth Moves, which one of these is NOT a Form?', 'The Hotshot', 'The Discard', 'The Elephant', 'The Mohawk');
INSERT INTO public."Question" VALUES (733, 2, 'What is the capital of Peru?', 'Lima', 'Santiago', 'Montevideo', 'Buenos Aires');
INSERT INTO public."Question" VALUES (539, 101, 'What are tiny Thwomps called in Super Mario World?', 'Thwimps', 'Little Thwomp', 'Mini Thwomp', 'Tiny Tims');
INSERT INTO public."Question" VALUES (735, 112, 'How many notes are there on a standard grand piano?', '88', '98', '108', '78');
INSERT INTO public."Question" VALUES (541, 101, 'What was the name of the Wu-Tang Clan album Martin Shkreli bought for $2 million dollars?', 'Once Upon a Time in Shaolin', 'A Better Tomorrow', '8 Diagrams', 'The Saga Continues');
INSERT INTO public."Question" VALUES (747, 147, 'What is the code name for the mobile operating system Android 7.0?', 'Nougat', 'Ice Cream Sandwich', 'Jelly Bean', 'Marshmallow');
INSERT INTO public."Question" VALUES (749, 2, 'Which of these is NOT an Australian state or territory?', 'Alberta', 'New South Wales', 'Victoria', 'Queensland');
INSERT INTO public."Question" VALUES (801, 104, 'Which of these chemical compounds is NOT found in gastric acid?', 'Sulfuric acid', 'Hydrochloric acid', 'Potassium chloride', 'Sodium chloride');
INSERT INTO public."Question" VALUES (803, 2, 'The towns of Brugelette, Arlon and Ath are located in which country?', 'Belgium', 'Andorra', 'France', 'Luxembourg');
INSERT INTO public."Question" VALUES (544, 101, 'In Breaking Bad, the initials W.W. refer to which of the following?', 'Walter White', 'William Wolf', 'Willy Wonka', 'Wally Walrus');
INSERT INTO public."Question" VALUES (701, 101, 'Which animation studio animated "Hidamari Sketch"?', 'Shaft', 'Trigger', 'Kyoto Animation', 'Production I.G');
INSERT INTO public."Question" VALUES (736, 101, 'Which of the following guitarists recorded an album as a member of the Red Hot Chili Peppers?', 'Dave Navarro', 'Tom Morello ', 'Billy Corgan', 'Ed O''Brien');
INSERT INTO public."Question" VALUES (739, 112, 'What is the romanized Arabic word for "moon"?', 'Qamar', 'Najma', 'Kawkab', 'Shams');
INSERT INTO public."Question" VALUES (742, 101, 'In "Toriko", which of the following Heavenly Kings has an enhanced sense of Hearing?', 'Zebra', 'Coco', 'Sunny', 'Toriko');
INSERT INTO public."Question" VALUES (703, 101, 'In Left 4 Dead, what is the name of the virus, as designated by CEDA, that causes most humans to turn into the Infected?', 'Green Flu', 'Yellow Fever', 'T-Virus', 'Raspberry Sniffles');
INSERT INTO public."Question" VALUES (704, 101, 'Just Cause 2 was mainly set in what fictional Southeast Asian island country?', 'Panau', 'Davao', 'Macau', 'Palau');
INSERT INTO public."Question" VALUES (705, 101, 'What is the oldest Disney film?', 'Snow White and the Seven Dwarfs', 'Pinocchio', 'Dumbo', 'Fantasia');
INSERT INTO public."Question" VALUES (706, 101, 'What video game engine does the videogame Quake 2 run in?', 'iD Tech 2', 'iD Tech 3', 'iD Tech 1', 'Unreal Engine');
INSERT INTO public."Question" VALUES (808, 105, 'When did Spanish Peninsular War start?', '1808', '1806', '1810', '1809');
INSERT INTO public."Question" VALUES (448, 101, 'Which of these "Worms" games featured 3D gameplay?', 'Worms 4: Mayhem', 'Worms W.M.D', 'Worms Reloaded', 'Worms: Open Warfare 2');
INSERT INTO public."Question" VALUES (814, 325, 'What is the name of the Greek god of blacksmiths?', 'Hephaestus', 'Dyntos', 'Vulcan', 'Artagatus');
INSERT INTO public."Question" VALUES (816, 143, 'Who won the 2018 Monaco Grand Prix?', 'Daniel Ricciardo', 'Sebastian Vettel', 'Kimi Raikkonen', 'Lewis Hamilton');
INSERT INTO public."Question" VALUES (505, 101, 'In "Fallout 4" which faction is not present in the game?', 'The Enclave', 'The Minutemen', 'The Brotherhood of Steel', 'The Institute');
INSERT INTO public."Question" VALUES (824, 2, 'What is the capital of India?', 'New Delhi', 'Bejing', 'Montreal', 'Tithi');
INSERT INTO public."Question" VALUES (826, 112, 'What year was the RoboSapien toy robot released?', '2004', '2000', '2001', '2006');
INSERT INTO public."Question" VALUES (829, 128, 'Which of the following car manufacturers had a war named after it?', 'Toyota', 'Honda', 'Ford', 'Volkswagen');
INSERT INTO public."Question" VALUES (528, 101, 'For the film "Raiders of The Lost Ark", what was Harrison Ford sick with during the filming of the Cairo chase?', 'Dysentery', 'Anemia', 'Constipation', 'Acid Reflux ');
INSERT INTO public."Question" VALUES (844, 143, 'Which soccer team won the Copa America 2015 Championship ?', 'Chile', 'Argentina', 'Brazil', 'Paraguay');
INSERT INTO public."Question" VALUES (833, 143, 'What team did England beat in the semi-final stage to win in the 1966 World Cup final?', 'Portugal', 'West Germany', 'Soviet Union', 'Brazil');
INSERT INTO public."Question" VALUES (837, 112, 'The Canadian $1 coin is colloquially known as a what?', 'Loonie', 'Boolie', 'Foolie', 'Moodie');
INSERT INTO public."Question" VALUES (839, 2, 'What year is on the flag of the US state Wisconsin?', '1848', '1634', '1783', '1901');
INSERT INTO public."Question" VALUES (840, 147, 'What does LTS stand for in the software market?', 'Long Term Support', 'Long Taco Service', 'Ludicrous Transfer Speed', 'Ludicrous Turbo Speed');
INSERT INTO public."Question" VALUES (817, 333, 'What French sculptor designed the Statue of Liberty? ', 'Frederic Auguste Bartholdi', 'Jean-Leon Gercme', 'Auguste Rodin', 'Henri Matisse');
INSERT INTO public."Question" VALUES (843, 128, 'Automobiles produced by Tesla Motors operate on which form of energy?', 'Electricity', 'Gasoline', 'Diesel', 'Nuclear');
INSERT INTO public."Question" VALUES (846, 333, 'Painter Piet Mondrian (1872 - 1944) was a part of what movement?', 'Neoplasticism', 'Precisionism', 'Cubism', 'Impressionism');
INSERT INTO public."Question" VALUES (531, 101, 'Who directed the 1973 film "American Graffiti"?', 'George Lucas', 'Ron Howard', 'Francis Ford Coppola', 'Steven Spielberg');
INSERT INTO public."Question" VALUES (628, 101, 'What former MOBA, created by Waystone Games and published by EA, was shut down in 2014?', 'Dawngate', 'Strife', 'League of Legends', 'Heroes of Newerth');
INSERT INTO public."Question" VALUES (850, 147, 'What is the domain name for the country Tuvalu?', '.tv', '.tu', '.tt', '.tl');
INSERT INTO public."Question" VALUES (901, 2, 'What continent is the country Lesotho in?', 'Africa', 'Asia', 'South America', 'Europe');
INSERT INTO public."Question" VALUES (903, 2, 'Which of these is NOT a real tectonic plate?', 'Atlantic Plate', 'North American Plate', 'Eurasian Plate', 'Nazca Plate');
INSERT INTO public."Question" VALUES (904, 2, 'Which is the largest freshwater lake in the world?', 'Lake Superior ', 'Caspian Sea', 'Lake Michigan', 'Lake Huron');
INSERT INTO public."Question" VALUES (905, 2, 'Bir Tawil, an uninhabited track of land claimed by no country, is located along the border of which two countries?', 'Egypt and Sudan', 'Israel and Jordan', 'Chad and Libya', 'Iraq and Saudi Arabia');
INSERT INTO public."Question" VALUES (906, 104, 'What is the largest living organism currently known to man?', 'Honey Fungus', 'Blue Whale', 'Redwood Tree', 'The Coral Reef');
INSERT INTO public."Question" VALUES (908, 128, 'Which of the following car models has been badge-engineered (rebadged) the most?', 'Isuzu Trooper', 'Holden Monaro', 'Suzuki Swift', 'Chevy Camaro');
INSERT INTO public."Question" VALUES (637, 101, 'Who was the first female protagonist in a video game?', 'Samus Aran', 'Lara Croft', 'Alis Landale', 'Chell');
INSERT INTO public."Question" VALUES (825, 101, 'Who is the colossal titan in "Attack On Titan"?', 'Bertolt Hoover', 'Reiner', 'Eren', 'Sasha');
INSERT INTO public."Question" VALUES (643, 101, 'In the Hellboy universe, who founded the BPRD?', 'Trevor Bruttenholm', 'Kate Corrigan', 'Johann Kraus', 'Benjamin Daimio');
INSERT INTO public."Question" VALUES (841, 101, 'In which manga did the "404 Girl" from 4chan originate from?', 'Yotsuba&!', 'Azumanga Daioh', 'Lucky Star', 'Clover');
INSERT INTO public."Question" VALUES (645, 101, 'In Portal 2, how did CEO of Aperture Science, Cave Johnson, presumably die?', 'Moon Rock Poisoning', 'Accidentally sending a portal to the Moon', 'Slipped in the shower', 'Asbestos Poisoning');
INSERT INTO public."Question" VALUES (604, 101, 'In "The Simpsons", where did Homer and Marge first meet?', 'At Summer Camp', 'At High School', 'At Church', 'At 742 Evergreen Terrace');
INSERT INTO public."Question" VALUES (609, 101, 'In which "Call of Duty" game are the "Apothicons" introduced in the Zombies mode?', 'Call Of Duty: Black Ops III', 'Call Of Duty: Black Ops', 'Call Of Duty: World At War', 'Call Of Duty: Black Ops II');
INSERT INTO public."Question" VALUES (613, 101, 'What is the make and model of the tour vehicles in "Jurassic Park" (1993)?', '1992 Ford Explorer XLT', '1992 Toyota Land Cruiser', '1992 Jeep Wrangler YJ Sahar', 'Mercedes M-Class');
INSERT INTO public."Question" VALUES (910, 105, 'The Tsar Bomba, the most powerful nuclear bomb ever tested, had a yield of 50 megatons but theoretically had a maximum yield of how much?', '100 Megatons', '200 Megatons', '75 Megatons', '150 Megatons');
INSERT INTO public."Question" VALUES (938, 105, 'The ancient city of Chichen Itza was built by which civilization?', 'Mayans', 'Aztecs', 'Incas', 'Toltecs');
INSERT INTO public."Question" VALUES (916, 128, 'Which of these cars is NOT considered one of the 5 Modern Supercars by Ferrari?', 'Testarossa', 'Enzo Ferrari', 'F40', '288 GTO');
INSERT INTO public."Question" VALUES (917, 104, 'Which type of rock is created by intense heat AND pressure?', 'Metamorphic', 'Sedimentary', 'Igneous', 'Diamond');
INSERT INTO public."Question" VALUES (920, 112, 'What is the Swedish word for "window"?', 'Fonster', 'Venster', 'Skarm', 'Ruta');
INSERT INTO public."Question" VALUES (928, 112, 'How many furlongs are there in a mile?', 'Eight', 'Two', 'Four', 'Six');
INSERT INTO public."Question" VALUES (932, 101, 'In the anime Black Butler, who is betrothed to be married to Ciel Phantomhive?', 'Elizabeth Midford', 'Rachel Phantomhive', 'Alexis Leon Midford', 'Angelina Dalles');
INSERT INTO public."Question" VALUES (913, 101, 'Pete Townshend collaborated with which famous guitarist for an event at Brixton Academy in 1985?', 'David Gilmour', 'Jimmy Page', 'Mark Knopfler', 'Eric Clapton');
INSERT INTO public."Question" VALUES (615, 101, '"The Singing Cowboy" Gene Autry is credited with the first recording for all but which classic Christmas jingle?', 'White Christmas', 'Frosty the Snowman', 'Rudolph the Red-Nosed Reindeer', 'Here Comes Santa Claus');
INSERT INTO public."Question" VALUES (624, 101, 'Which country does the YouTuber "SinowBeats" originate from?', 'Scotland', 'England', 'Sweden', 'Germany');
INSERT INTO public."Question" VALUES (647, 101, 'Which of these is NOT a song featured on the Lockjaw EP released in 2013 by Flume & Chet Faker?', 'Left Alone', 'What About Us', 'This Song Is Not About A Girl', 'Drop The Game');
INSERT INTO public."Question" VALUES (1005, 147, 'Which computer hardware device provides an interface for all other connected devices to communicate?', 'Motherboard', 'Central Processing Unit', 'Hard Disk Drive', 'Random Access Memory');
INSERT INTO public."Question" VALUES (1006, 105, 'In what year did the Great Northern War, between Russia and Sweden, end?', '1721', '1726', '1727', '1724');
INSERT INTO public."Question" VALUES (707, 101, 'What was Raekwon the Chefs debut solo album?', 'Only Built 4 Cuban Linx', 'Shaolin vs Wu-Tang', 'The Wild', 'The Lex Diamond Story');
INSERT INTO public."Question" VALUES (1009, 147, 'What was the first commerically available computer processor?', 'Intel 4004', 'Intel 486SX', 'TMS 1000', 'AMD AM386');
INSERT INTO public."Question" VALUES (1010, 112, 'Which American-owned brewery led the country in sales by volume in 2015?', 'D. G. Yuengling and Son, Inc', 'Anheuser Busch', 'Boston Beer Company', 'Miller Coors');
INSERT INTO public."Question" VALUES (1017, 102, 'By definition, where does an abyssopelagic animal live?', 'At the bottom of the ocean', 'In the desert', 'On top of a mountain', 'Inside a tree');
INSERT INTO public."Question" VALUES (709, 101, 'Which pulp hero made appearances in Hellboy and BPRD comics before getting his own spin-off?', 'Lobster Johnson', 'Roger the Homunculus', 'The Spider', 'The Wendigo');
INSERT INTO public."Question" VALUES (1013, 101, 'What was the name of the Secret Organization in the Hotline Miami series? ', '50 Blessings', 'American Blessings', '50 Saints', 'USSR''s Blessings');
INSERT INTO public."Question" VALUES (745, 101, 'What is the name of your team in Star Wars: Republic Commando?', 'Delta Squad', 'The Commandos', 'Bravo Six', 'Vader''s Fist');
INSERT INTO public."Question" VALUES (946, 2, 'Where is the fast food chain "Panda Express" headquartered?', 'Rosemead, California', 'Sacramento, California', 'Fresno, California', 'San Diego, California');
INSERT INTO public."Question" VALUES (714, 101, 'In the Portal series of games, who was the founder of Aperture Science?', 'Cave Johnson', 'GLaDOs', 'Wallace Breen', 'Gordon Freeman');
INSERT INTO public."Question" VALUES (702, 101, 'Which of following is rude and dishonorable by Klingon standards?', 'Taking his D''k tahg', 'Insulting and laughing at him at the dinner table', 'Reaching over and taking his meal', 'Punching him and taking his ship station position');
INSERT INTO public."Question" VALUES (1022, 112, 'Named after the mallow flower, mauve is a shade of what?', 'Purple', 'Red', 'Brown', 'Pink');
INSERT INTO public."Question" VALUES (1109, 2, 'What was the most populous city in the Americas in 2015?', 'Sao Paulo', 'New York', 'Mexico City', 'Los Angeles');
INSERT INTO public."Question" VALUES (727, 101, 'Who voices for Ruby in the animated series RWBY?', 'Lindsay Jones', 'Tara Strong', 'Jessica Nigri', 'Hayden Panettiere');
INSERT INTO public."Question" VALUES (732, 101, 'Europa Universalis is a strategy video game based on which French board game?', 'Europa Universalis', 'Europe and the Universe', 'Europa!', 'Power in Europe');
INSERT INTO public."Question" VALUES (1030, 128, 'Complete the following analogy: Audi is to Volkswagen as Infiniti is to ?', 'Nissan', 'Honda', 'Hyundai', 'Subaru');
INSERT INTO public."Question" VALUES (737, 101, 'Which song is not by TheFatRat?', 'Ascent', 'Monody', 'Windfall', 'Infinite Power!');
INSERT INTO public."Question" VALUES (1032, 112, 'Which sign of the zodiac comes between Virgo and Scorpio?', 'Libra', 'Gemini', 'Taurus', 'Capricorn');
INSERT INTO public."Question" VALUES (740, 101, 'In the Homestuck Series, what is the alternate name for the Kingdom of Lights?', 'Prospit', 'No Name', 'Golden City', 'Yellow Moon');
INSERT INTO public."Question" VALUES (744, 101, 'Who is the creator of Touhou project?', 'Zun', 'Jun', 'Twilight Frontier', 'Tasofro');
INSERT INTO public."Question" VALUES (746, 101, 'What is the real hair colour of the mainstream comic book version (Earth-616) of Daredevil?', 'Blonde', 'Auburn', 'Brown', 'Black');
INSERT INTO public."Question" VALUES (1046, 112, 'In past times, what would a gentleman keep in his fob pocket?', 'Watch', 'Money', 'Keys', 'Notebook');
INSERT INTO public."Question" VALUES (1048, 147, 'The numbering system with a radix of 16 is more commonly referred to as ', 'Hexidecimal', 'Binary', 'Duodecimal', 'Octal');
INSERT INTO public."Question" VALUES (1049, 2, 'In the 2016 Global Peace Index poll, out of 163 countries, what was the United States of America ranked?', '103', '10', '59', '79');
INSERT INTO public."Question" VALUES (748, 101, 'Which of these is not a real character in the cartoon series My Little Pony: Friendship is Magic?', 'Rose Marene', 'Pinkie Pie', 'Maud Pie', 'Rainbow Dash');
INSERT INTO public."Question" VALUES (750, 101, 'In Bionicle, who was formerly a Av-Matoran and is now the Toa of Light?', 'Takua', 'Jaller', 'Vakama', 'Tahu');
INSERT INTO public."Question" VALUES (720, 101, 'Who recorded the album called "Down to the Moon" in 1986?', 'Andreas Vollenweider', 'Jean-Michel Jarre', 'Bing Crosby', 'Enya');
INSERT INTO public."Question" VALUES (1107, 105, 'Which country was an allied power in World War II?', 'Soviet Union', 'Italy', 'Germany', 'Japan');
INSERT INTO public."Question" VALUES (726, 101, 'What breed of dog is "Scooby Doo"?', 'Great Dane', 'Pit bull', 'Boxer', 'Doberman Pinscher');
INSERT INTO public."Question" VALUES (1110, 101, 'What caused the titular mascot of Yo-Kai Watch, Jibanyan, to become a yokai?', 'Being run over by a truck', 'Ate one too many chocobars', 'Through a magical ritual', 'When he put on the harmaki');
INSERT INTO public."Question" VALUES (1112, 239, 'To the nearest whole number, how many radians are in a whole circle?', '6', '3', '4', '5');
INSERT INTO public."Question" VALUES (1117, 333, 'Who painted the epic mural Guernica?', 'Pablo Picasso', 'Francisco Goya', 'Leonardo da Vinci', 'Henri Matisse');
INSERT INTO public."Question" VALUES (1119, 105, 'Which country was Josef Stalin born in?', 'Georgia', 'Russia', 'Germany', 'Poland');
INSERT INTO public."Question" VALUES (1123, 2, 'If soccer is called football in England, what is American football called in England?', 'American football', 'Combball', 'Handball', 'Touchdown');
INSERT INTO public."Question" VALUES (1125, 105, 'What happened on June 6, 1944?', 'D-Day', 'Atomic bombings of Hiroshima and Nagasaki', 'Attack on Pearl Harbor', 'The Liberation of Paris');
INSERT INTO public."Question" VALUES (1040, 147, 'What does the "MP" stand for in MP3?', 'Moving Picture', 'Music Player', 'Multi Pass', 'Micro Point');
INSERT INTO public."Question" VALUES (1111, 104, 'What is "Stenoma"?', 'A genus of moths', 'A combat stimulant from WW2', 'A type of seasoning', 'A port city in the carribean');
INSERT INTO public."Question" VALUES (738, 101, 'Which of these weapons is NOT available to the Terrorist team in the game, "Counter-Strike: Global Offensive"?', 'SCAR-20', 'SG 550', 'CZ-75', 'XM1014');
INSERT INTO public."Question" VALUES (802, 101, 'Which year was the album "Floral Shoppe" by Macintosh Plus released?', '2011', '2014', '2013', '2012');
INSERT INTO public."Question" VALUES (805, 101, 'Who directed the Kill Bill movies?', 'Quentin Tarantino', 'Arnold Schwarzenegger', 'David Lean', 'Stanley Kubrick');
INSERT INTO public."Question" VALUES (1020, 101, 'In season one of the US Kitchen Nightmares, Gordan Ramsay tried to save 10 different restaurants. How many ended up closing afterwards?', '9', '6', '3', '0');
INSERT INTO public."Question" VALUES (1129, 105, 'Who was the President of the United States during the signing of the Gadsden Purchase?', 'Franklin Pierce', 'Andrew Johnson', 'Abraham Lincoln', 'James Polk');
INSERT INTO public."Question" VALUES (1132, 105, 'The Panama Canal was finished under the administration of which U.S. president?', 'Woodrow Wilson', 'Franklin Delano Roosevelt', 'Herbert Hoover', 'Theodore Roosevelt');
INSERT INTO public."Question" VALUES (1139, 2, 'Which of these countries is NOT located in Africa?', 'Suriname', 'Burkina Faso', 'Mozambique', 'Algeria');
INSERT INTO public."Question" VALUES (1144, 112, 'What alcoholic drink is made from molasses?', 'Rum', 'Gin', 'Vodka', 'Whisky');
INSERT INTO public."Question" VALUES (818, 101, 'Which "Fallout: New Vegas" quest is NOT named after a real-life song?', 'They Went That-a-Way', 'Come Fly With Me', 'Ain''t That a Kick in the Head', 'Ring-a-Ding Ding');
INSERT INTO public."Question" VALUES (1147, 143, 'Which car company is the only Japanese company which won the 24 Hours of Le Mans?', 'Mazda', 'Toyota', 'Subaru', 'Nissan');
INSERT INTO public."Question" VALUES (827, 101, 'The starting pistol of the Terrorist team in a competitive match of Counter Strike: Global Offensive is what?', 'Glock-18', 'Tec-9', 'Desert Eagle', 'Dual Berretas');
INSERT INTO public."Question" VALUES (828, 101, 'On a standard Monopoly board, how much do you have to pay for Tennessee Ave?', '$180', '$200', '$160', '$220');
INSERT INTO public."Question" VALUES (830, 101, 'Who was the voice actor for Snake in Metal Gear Solid V: The Phantom Pain?', 'Kiefer Sutherland', 'David Hayter', 'Norman Reedus', 'Hideo Kojima');
INSERT INTO public."Question" VALUES (834, 101, 'What genre of EDM is the Dutch DJ, musician, and remixer Armin van Buuren most well-known for?', 'Trance', 'House', 'Drum and Bass', 'Dubstep');
INSERT INTO public."Question" VALUES (836, 101, 'In The Lies of Locke Lamora, what title is Locke known by in the criminal world?', 'The Thorn of Camorr', 'The Rose of the Marrows', 'The Thorn of Emberlain', 'The Thorn of the Marrows');
INSERT INTO public."Question" VALUES (810, 101, 'What is the name of the song by Beyonce and Alejandro Fernandez released in 2007?', 'Amor Gitano', 'La ultima vez', 'Rocket', 'Hasta Dondes Estes');
INSERT INTO public."Question" VALUES (845, 101, 'In which Mario game did the Mega Mushroom make its debut?', 'Mario Party 4', 'New Super Mario Bros.', 'Mario Kart Wii', 'Super Mario 3D World');
INSERT INTO public."Question" VALUES (849, 101, 'When Batman trolls the online chat rooms, what alias does he use?', 'JonDoe297', 'iAmBatman', 'BWayne13', 'BW1129');
INSERT INTO public."Question" VALUES (902, 101, 'In the Mario Kart and Smash Bros. Games, Princess Rosalina is considered what weight class?', 'Heavy', 'Medium', 'Light', 'Light-Medium');
INSERT INTO public."Question" VALUES (909, 101, 'Who was the lead singer and frontman of rock band R.E.M?', 'Michael Stipe', 'Chris Martin', 'Thom Yorke', 'George Michael');
INSERT INTO public."Question" VALUES (806, 101, 'What name did "Mario", from "Super Mario Brothers", originally have?', 'Ossan', 'Jumpman', 'Mr. Video', 'Mario');
INSERT INTO public."Question" VALUES (811, 101, 'Which band released the album "Sonic Highways" in 2014?', 'Foo Fighters', 'Coldplay', 'Nickelback', 'The Flaming Lips');
INSERT INTO public."Question" VALUES (322, 143, 'Which Formula One driver was nicknamed ''The Professor''?', 'Alain Prost', 'Ayrton Senna', 'Niki Lauda', 'Emerson Fittipaldi');
INSERT INTO public."Question" VALUES (406, 112, 'What is the world''s most expensive spice by weight?', 'Saffron', 'Cinnamon', 'Cardamom', 'Vanilla');
INSERT INTO public."Question" VALUES (813, 101, 'In "The Simpsons", what is the real name of "Comic Book Guy"?', 'Jeff Albertson', 'Comic Book Guy', 'Edward Stone', 'Jack Richardson');
INSERT INTO public."Question" VALUES (820, 101, 'The 2016 song "Starboy" by Canadian singer The Weeknd features which prominent electronic artist?', 'Daft Punk', 'deadmau5', 'Disclosure', 'DJ Shadow');
INSERT INTO public."Question" VALUES (822, 101, 'What are Sans and Papyrus named after in "Undertale"?', 'Fonts', 'Plants', 'Companies', 'Ancient writing paper');
INSERT INTO public."Question" VALUES (835, 101, 'In Fallout 4, which type of power armor is first encountered in the early mission "When Freedom Calls" in a crashed Vertibird?', 'T-45', 'T-51', 'T-60', 'X-01');
INSERT INTO public."Question" VALUES (918, 101, 'Brendan Fraser starred in the following movies, except which one?', 'Titanic', 'Monkeybone', 'Encino Man', 'Mrs. Winterbourne');
INSERT INTO public."Question" VALUES (919, 101, 'What is the default alias that Princess Garnet goes by in Final Fantasy IX?', 'Dagger', 'Dirk', 'Garnet', 'Quina');
INSERT INTO public."Question" VALUES (1126, 104, 'The "Tibia" is found in which part of the body?', 'Leg', 'Arm', 'Hand', 'Head');
INSERT INTO public."Question" VALUES (1127, 101, 'Which one of these Rammstein songs has two official music videos?', 'Du Riechst So Gut', 'Du Hast', 'Benzin', 'Mein Teil');
INSERT INTO public."Question" VALUES (1131, 325, 'What mythology did the god "Apollo" come from?', 'Greek and Roman', 'Roman and Spanish', 'Greek and Chinese', 'Greek, Roman and Norse');
INSERT INTO public."Question" VALUES (1133, 147, 'In "Hexadecimal", what color would be displayed from the color code? "#00FF00"?', 'Green', 'Red', 'Blue', 'Yellow');
INSERT INTO public."Question" VALUES (924, 101, 'How many points is the Z tile worth in Scrabble?', '10', '8', '5', '6');
INSERT INTO public."Question" VALUES (1019, 101, 'The name of the Metroid series comes from what?', 'An enemy in the game', 'The final boss''s name', 'The main character''s name', 'A spaceship''s name');
INSERT INTO public."Question" VALUES (1012, 101, 'Which of the following Zelda games did not feature Ganon as a final boss?', 'Majora''s Mask', 'Ocarina of Time', 'Skyward Sword', 'Breath of the Wild');
INSERT INTO public."Question" VALUES (1135, 101, 'The creeper in Minecraft was the result of a bug while implementing which creature?', 'Pig', 'Zombie', 'Chicken', 'Cow');
INSERT INTO public."Question" VALUES (526, 147, 'Lenovo acquired IBM''s personal computer division, including the ThinkPad line of laptops and tablets, in what year?', '2005', '1999', '2002', '2008');
INSERT INTO public."Question" VALUES (550, 2, 'What is the only country in the world with a flag that doesn''t have four right angles?', 'Nepal', 'Panama', 'Angola', 'Egypt');
INSERT INTO public."Question" VALUES (730, 147, 'According to DeMorgan''s Theorem, the Boolean expression (AB)'' is equivalent to:', 'A'' + B''', 'A''B + B''A', 'A''B''', 'AB'' + AB');
INSERT INTO public."Question" VALUES (617, 104, '71% of the Earth''s surface is made up of', 'Water', 'Deserts', 'Continents', 'Forests');
INSERT INTO public."Question" VALUES (646, 2, 'What''s the first National Park designated in the United States?', 'Yellowstone', 'Sequoia ', 'Yosemite', 'Rocky Mountain');
INSERT INTO public."Question" VALUES (718, 128, 'What do the 4 Rings in Audi''s Logo represent?', 'Previously independent automobile manufacturers', 'States in which Audi makes the most sales', 'Main cities vital to Audi', 'Countries in which Audi makes the most sales');
INSERT INTO public."Question" VALUES (809, 143, 'Which city features all of their professional sports teams'' jersey''s with the same color scheme?', 'Pittsburgh', 'New York', 'Seattle', 'Tampa Bay');
INSERT INTO public."Question" VALUES (821, 2, 'Which of the following is not a megadiverse country - one that harbors a high number of the earth''s endemic species?', 'Thailand', 'Peru', 'Mexico', 'South Africa');
INSERT INTO public."Question" VALUES (838, 101, 'The main protagonist of the fifth part of JoJo''s Bizarre Adventure is which of the following?', 'Giorno Giovanna', 'Guido Mista', 'Jonathan Joestar', 'Joey JoJo');
INSERT INTO public."Question" VALUES (1007, 105, 'What was Napoleon Bonaparte''s name before he changed it?', 'Napoleone di Buonaparte', 'Naapolion van Bonijpaart', 'Napoleao do Boaparte', 'Napoleona de Buenoparte');
INSERT INTO public."Question" VALUES (1023, 128, 'Which country has the international vehicle registration letter ''A''?', 'Austria', 'Afghanistan', 'Australia', 'Armenia');
INSERT INTO public."Question" VALUES (525, 104, 'What animal takes part in Schrodinger''s most famous thought experiment?', 'Cat', 'Dog', 'Bat', 'Butterfly');
INSERT INTO public."Question" VALUES (1033, 101, 'What is the name of Funny Valentine''s stand in Jojo''s Bizarre Adventure Part 7, Steel Ball Run?', 'Dirty Deeds Done Dirt Cheap', 'Filthy Acts Done For A Reasonable Price', 'Civil War', 'God Bless The USA');
INSERT INTO public."Question" VALUES (717, 105, 'What was Genghis Khan''s real name?', 'Temujin', 'Mongke', 'Ogedei', 'Temur');
INSERT INTO public."Question" VALUES (930, 101, 'Which character does voice actress Tara Strong NOT voice?', 'Bubbles (2016)', 'Twilight Sparkle', 'Timmy Turner', 'Harley Quinn');
INSERT INTO public."Question" VALUES (933, 101, 'In Undertale, how much do Spider Donuts cost in Hotland?', '9999G', '7G', '40G', '12G');
INSERT INTO public."Question" VALUES (940, 101, 'What ability does Princess Sofia the First have from her amulet that allows her to breathe underwater?', 'Mermaid Transformation', 'Artificial Gills', 'Bubble Head', 'Bubble Shield');
INSERT INTO public."Question" VALUES (941, 101, 'EDM producer Marshmello performs live wearing clothes and a marshmallow mask of what colour?', 'White', 'Black', 'Blue', 'Yellow');
INSERT INTO public."Question" VALUES (943, 101, 'In the Kingdom Heart series who provides the english voice for Master Eraqus?', 'Mark Hamill', 'Jason Dohring', 'Jesse McCartney', 'Haley Joel Osment');
INSERT INTO public."Question" VALUES (947, 101, 'In Touhou 12: Undefined Fantastic Object, which of these was not a playable character?', 'Izayoi Sakuya', 'Hakurei Reimu', 'Kirisame Marisa', 'Kochiya Sanae');
INSERT INTO public."Question" VALUES (521, 101, 'In Terry Pratchett''s Discworld novel ''Wyrd Sisters'', which of these are not one of the three main witches?', 'Winny Hathersham', 'Granny Weatherwax', 'Nanny Ogg', 'Magrat Garlick');
INSERT INTO public."Question" VALUES (728, 101, 'In South Park, what is Stan''s surname?', 'Marsh', 'Stotch', 'Broflovski', 'Tweak');
INSERT INTO public."Question" VALUES (1050, 101, 'Which part from the JoJo''s Bizarre Adventure manga is about a horse race across America?', 'Part 7: Steel Ball Run', 'Part 6: Stone Ocean', 'Part 3: Stardust Crusaders', 'Part 5: Golden Wind');
INSERT INTO public."Question" VALUES (948, 101, 'Which is NOT a book in the Harry Potter Series?', 'The House Elf', 'The Chamber of Secrets', 'The Prisoner of Azkaban', 'The Deathly Hallows');
INSERT INTO public."Question" VALUES (1142, 104, 'The ''Islets of Langerhans'' is found in which human organ?', 'Pancreas', 'Kidney', 'Liver', 'Brain');
INSERT INTO public."Question" VALUES (1145, 112, 'Virtual reality company Oculus VR lost which of it''s co-founders in a freak car accident in 2013?', 'Andrew Scott Reisse', 'Nate Mitchell', 'Jack McCauley', 'Palmer Luckey');
INSERT INTO public."Question" VALUES (123, 123, 'Mobile hardware and software company "Blackberry Limited" was founded in which country?', 'Canada', 'Norway', 'United States of America', 'United Kingdom');
INSERT INTO public."Question" VALUES (332, 112, 'What is the Italian word for "tomato"?', 'Pomodoro', 'Aglio', 'Cipolla', 'Peperoncino');
INSERT INTO public."Question" VALUES (333, 333, 'Who painted "The Starry Night"?', 'Vincent van Gogh', 'Edvard Munch', 'Pablo Picasso', 'Claude Monet');
INSERT INTO public."Question" VALUES (540, 105, 'In addition to his career as an astrologer and "prophet", Nostradamus published a 1555 treatise that included a section on what?', 'Making jams and jellies', 'Teaching parrots to talk', 'Cheating at card games', 'Digging graves');
INSERT INTO public."Question" VALUES (543, 333, 'Who painted "Swans Reflecting Elephants", "Sleep", and "The Persistence of Memory"?', 'Salvador Dali', 'Jackson Pollock', 'Vincent van Gogh', 'Edgar Degas');
INSERT INTO public."Question" VALUES (545, 101, 'What year did the anime "Himouto! Umaru-chan" air?', '2015', '2014', '2012', '2013');
INSERT INTO public."Question" VALUES (641, 101, 'Satella in "Re:Zero" is the witch of what?', 'Envy', 'Pride', 'Sloth', 'Wrath');
INSERT INTO public."Question" VALUES (642, 101, 'In "Inuyasha", what are the heros are looking to collect?', 'Jewel Shards', 'Dragon Balls', 'Rave Stones', 'Sacred Stones');
INSERT INTO public."Question" VALUES (208, 101, 'In the "Re:Zero" manga series, which of the following Sin Archbishops eats Rem''s existence?', 'Ley Batenkaitos', 'Roy Alphard', 'Petelgeuse Romanee-Conti', 'Louis Arneb');
INSERT INTO public."Question" VALUES (950, 101, 'One of the Nintendo Entertainment System voice channels supports playback of sound samples. Which one?', 'DMC', 'Noise', 'Triangle', 'Square');
INSERT INTO public."Question" VALUES (1002, 101, 'Which horror movie had a sequel in the form of a video game released in August 20, 2002?', 'The Thing', 'The Evil Dead', 'Saw', 'Alien');
INSERT INTO public."Question" VALUES (502, 101, 'Akatsuki''s subclass in "Log Horizon" is what?', ' Tracker', 'Assassin', 'Scribe', 'Apprentice');
INSERT INTO public."Question" VALUES (614, 101, 'Which of the following countries does "JoJo''s Bizarre Adventure: Stardust Crusaders" not take place in?', 'Philippines', 'India', 'Pakistan', 'Egypt');
INSERT INTO public."Question" VALUES (427, 101, 'What was the development code name for the "Urza''s Destiny" expansion for "Magic: The Gathering", released in 1999?', 'Chimichanga', 'Burrito', 'Taquito', 'Enchilada');
INSERT INTO public."Question" VALUES (1008, 101, 'What is the cartoon character, Andy Capp, known as in Germany?', 'Willi Wakker', 'Dick Tingeler', 'Helmut Schmacker', 'Rod Tapper');
INSERT INTO public."Question" VALUES (1011, 101, 'According to the American rapper Nelly, what should you do when its hot in here?', 'Take off all your clothes', 'Take a cool shower', 'Drink some water', 'Go skinny dipping');
INSERT INTO public."Question" VALUES (922, 101, 'In Naruto: Shippuden, which of the following elements is a "Kekkei Tōta?"', 'Particle Style', 'Any Doujutsu', 'Shadow Style', 'Ice Style');
INSERT INTO public."Question" VALUES (925, 101, 'What Led Zeppelin album contains "Stairway to Heaven"?', 'Led Zeppelin IV', 'Houses of the Holy', 'Physical Graffiti', 'Led Zeppelin III');
INSERT INTO public."Question" VALUES (931, 101, 'Which of the following was not one of "The Magnificent Seven"?', 'Clint Eastwood', 'Steve McQueen', 'Charles Bronson', 'Robert Vaughn');
INSERT INTO public."Question" VALUES (935, 101, 'In the "PAYDAY" series, what is the real name of the character known as "Dallas"?', 'Nathan Steele', 'Nate Siemens', 'Nick Stamos', 'Nolan Stuhlinger');
INSERT INTO public."Question" VALUES (939, 101, 'Who was the author of the 1954 novel, "Lord of the Flies"?', 'William Golding', 'Stephen King', 'F. Scott Fitzgerald', 'Hunter Fox');
INSERT INTO public."Question" VALUES (944, 101, 'Which company developed the video game "Borderlands"?', 'Gearbox Software', '2K Games', 'Activision', 'Rockstar Games');
INSERT INTO public."Question" VALUES (936, 101, 'Which one of these nations was added to Civilization V with the "Gods & Kings" expansion?', 'The Netherlands', 'The Zulu', 'The Ottomans', 'The Kongo');
INSERT INTO public."Question" VALUES (1021, 101, 'What was the date of original airing of the pilot episode of My Little Pony: Friendship is Magic?', 'October 10th, 2010', 'November 6th, 2010', 'April 14th, 1984', 'May 18th, 2015');
INSERT INTO public."Question" VALUES (1025, 101, 'What collaborative album was released by Kanye West and Jay-Z in 2011?', 'Watch the Throne', 'Distant Relatives', 'What a Time to be Alive', 'Unfinished Business');
INSERT INTO public."Question" VALUES (1026, 101, 'This trope refers to minor characters that are killed off to show how a monster works.', 'Red Shirt', 'Minions', 'Expendables', 'Cannon Fodder');
INSERT INTO public."Question" VALUES (1028, 101, 'Which boxer was famous for striking the gong in the introduction to J. Arthur Rank films?', 'Bombardier Billy Wells', 'Freddie Mills', 'Terry Spinks', 'Don Cockell');
INSERT INTO public."Question" VALUES (1035, 101, 'In Big Hero 6, what fictional city is the Big Hero 6 from?', 'San Fransokyo', 'San Tokyo', 'Tokysisco', 'Sankyo');
INSERT INTO public."Question" VALUES (1039, 101, 'What is the name of the largest planet in Kerbal Space Program?', 'Jool', 'Eeloo', 'Kerbol', 'Minmus');
INSERT INTO public."Question" VALUES (1043, 101, 'Which member of the Foo Fighters was previously the drummer for Nirvana?', 'Dave Grohl', 'Taylor Hawkins', 'Nate Mendel', 'Chris Shiflett');
INSERT INTO public."Question" VALUES (1044, 101, 'What is the correct spelling of the protagonist of the book in The NeverEnding Story (1984)?', 'Atreyu', 'Atrayu', 'Atraiyu', 'Atraeyu');
INSERT INTO public."Question" VALUES (1101, 101, 'Which Twitch streamer is the vocalist for Red Vox?', 'Vinesauce', 'The8BitDrummer', 'LIRIK', 'Sodapoppin');
INSERT INTO public."Question" VALUES (1102, 101, 'In Need for Speed: Underground, what car does Eddie drive?', 'Nissan Skyline GT-R (R34)', 'Mazda RX-7 FD3S', 'Acura Integra Type R', 'Subaru Impreza 2.5 RS');
INSERT INTO public."Question" VALUES (1106, 101, 'In August 1964, who introduced the Beatles to cannabis?', 'Bob Dylan', 'Jim Morrison', 'Brian Epstein', 'Jerry Garcia');
INSERT INTO public."Question" VALUES (1113, 101, 'Which animated movie was first to feature a celebrity as a voice actor?', 'Aladdin', 'Toy Story', 'James and the Giant Peach', 'The Hunchback of Notre Dame');
INSERT INTO public."Question" VALUES (1115, 101, 'What was the first monster to appear alongside Godzilla?', 'Anguirus', 'King Kong', 'Mothra', 'King Ghidora');
INSERT INTO public."Question" VALUES (1116, 101, 'Which of these Starbound races has a Wild West culture?', 'Novakid', 'Avian', 'Human', 'Hylotl');
INSERT INTO public."Question" VALUES (1118, 101, 'Who was the winner of the 2016 WWE Royal Rumble?', 'Triple H', 'Roman Reigns', 'AJ Styles', 'Dean Ambrose');
INSERT INTO public."Question" VALUES (1122, 101, 'In the National Pokedex what number is Porygon-Z?', '474', '376', '432', '589');
INSERT INTO public."Question" VALUES (1124, 101, 'Which actor plays Obi-Wan Kenobi in Star Wars Episodes I-lll?', 'Ewan McGregor', 'Alec Guinness', 'Hayden Christensen', 'Liam Neeson');
INSERT INTO public."Question" VALUES (1027, 101, 'What is the alter-ego of the DC comics character "Superman"?', 'Clark Kent', 'Bruce Wayne', 'Arthur Curry', 'John Jones');
INSERT INTO public."Question" VALUES (1034, 101, 'In "Kingdom Hearts", who abducts Jasmine in the Lamp Chamber?', 'Riku', 'Riku Replica', 'Xaldin', 'Captain Hook');
INSERT INTO public."Question" VALUES (1036, 101, 'What vault in the video game "Fallout 3" is the home of multiple clones named Gary?', 'Vault 108', 'Vault 101', 'Vault 87', 'Vault 21');
INSERT INTO public."Question" VALUES (1037, 101, 'Which rap group released the album "Straight Outta Compton"?', 'N.W.A', 'Wu-Tang Clan', 'Run-D.M.C.', 'Beastie Boys');
INSERT INTO public."Question" VALUES (1038, 101, 'What did Alfred Hitchcock use as blood in the film "Psycho"? ', 'Chocolate syrup', 'Ketchup', 'Red food coloring', 'Maple syrup');
INSERT INTO public."Question" VALUES (1114, 101, '"Tomb Raider" icon Lara Croft was originally called...', 'Laura Cruz', 'Laura Craft', 'Laura Croft', 'Lara Craft');
INSERT INTO public."Question" VALUES (1136, 101, 'Which of the following is NOT a work done by Shakespeare?', 'Trial of Temperance', 'Measure For Measure', 'Titus Andronicus', 'Cymbeline');
INSERT INTO public."Question" VALUES (1138, 101, 'In the Star Trek universe, what color is Vulcan blood?', 'Green', 'Blue', 'Red', 'Purple');
INSERT INTO public."Question" VALUES (1140, 101, 'Which unlockable character in Super Smash Bros. For Wii U and 3DS does not have to be fought to be unlocked?', 'Mii Fighters', 'Ness', 'R.O.B.', 'Mewtwo');
INSERT INTO public."Question" VALUES (1130, 101, 'Who was "Kung Fu Fighting" in 1974?', 'Carl Douglas', 'The Bee Gees', 'Heatwave', 'Kool & the Gang');
INSERT INTO public."Question" VALUES (428, 101, 'In Disney''s "Toontown Online", which of these species wasn''t available as a Toon?', 'Cow', 'Monkey', 'Bear', 'Pig');
INSERT INTO public."Question" VALUES (423, 101, 'In the Pokemon series, what is Palkia''s hidden ability?', 'Telepathy', 'Pressure', 'Water Bubble', 'Hydration');
INSERT INTO public."Question" VALUES (1146, 101, 'What year did the television company BBC officially launch the channel BBC One?', '1936', '1948', '1932', '1955');
INSERT INTO public."Question" VALUES (149, 101, 'Which ''Family Guy'' character got his own spin-off show in 2009?', 'Cleveland Brown', 'Glenn Quagmire', 'Joe Swanson', 'The Greased-up Deaf Guy');
INSERT INTO public."Question" VALUES (201, 101, 'In Danganronpa: Trigger Happy Havoc, what is the protagonist''s name?', 'Makoto Naegi', 'Hajime Hinata', 'Nagito Komaeda', 'Komaru Naegi');
INSERT INTO public."Question" VALUES (226, 101, 'Who had a 1969 top 5 hit with the song,  ''A Boy Named Sue''?', 'Johnny Cash', 'Bob Dylan', 'Willie Nelson', 'Kris Kristofferson');
INSERT INTO public."Question" VALUES (228, 101, 'What is the name of Finnish DJ Darude''s hit single released in October 1999?', 'Sandstorm', 'Dust Devil', 'Sirocco', 'Khamsin');
INSERT INTO public."Question" VALUES (350, 101, 'In the cartoon ''SpongeBob SquarePants'', what did the acronym E.V.I.L stand for?', 'Every Villain Is Lemons', 'Every Villain Is Lemonade', 'Every Villain Is Limes', 'Each Villain Is Lemonade');
INSERT INTO public."Question" VALUES (404, 101, 'Saul Hudson (Slash) of the band Guns N'' Roses is known for playing what type of guitar?', 'Les Paul Standard', 'Fender Stratocaster', 'LsL Mongrel', 'Gretsch Falcon');
INSERT INTO public."Question" VALUES (425, 101, 'What was Humphrey Bogart''s middle name?', 'DeForest', 'DeWinter', 'Steven', 'Bryce');
INSERT INTO public."Question" VALUES (501, 101, 'In which African country was the 2006 film ''Blood Diamond'' mostly set in?', 'Sierra Leone', 'Liberia', 'Burkina Faso', 'Central African Republic');
INSERT INTO public."Question" VALUES (1134, 101, 'What is Hermione Granger''s middle name?', 'Jean', 'Jane', 'Emma', 'Jo');
INSERT INTO public."Question" VALUES (309, 101, 'Which Shakespeare play inspired the musical ''West Side Story''?', 'Romeo & Juliet', 'Hamlet', 'Macbeth', 'Othello');
INSERT INTO public."Question" VALUES (538, 101, 'Which one of these games wasn''t released in 2016?', 'Metal Gear Solid V', 'Tom Clancy''s The Division', 'Killing Floor 2', 'Hitman');
INSERT INTO public."Question" VALUES (536, 101, 'What Magic: The Gathering card''s flavor text is just ''Ribbit.''?', 'Turn to Frog', 'Spore Frog', 'Bloated Toad', 'Frogmite');
INSERT INTO public."Question" VALUES (618, 101, 'What song on ScHoolboy Q''s album Black Face LP featured Kanye West?', 'THat Part', 'Neva CHange', 'Big Body', 'Blank Face');
INSERT INTO public."Question" VALUES (621, 101, 'In Calvin and Hobbes, what is the name of the babysitter''s boyfriend?', 'Charlie', 'Dave', 'Charles', 'Nathaniel');
INSERT INTO public."Question" VALUES (629, 101, 'Which character from the Mega Man series made a small cameo on Volt Catfish''s introduction scene in CD versions of Mega Man X3?', 'Auto', 'Eddie', 'Tango', 'Rush');
INSERT INTO public."Question" VALUES (648, 101, 'On a standard Monopoly board, which square is diagonally opposite ''Go''? ', 'Free Parking', 'Go to Jail', 'Jail', 'The Electric Company');
INSERT INTO public."Question" VALUES (650, 101, 'In World of Warcraft lore, which of the following is known as the God of Spiders in the troll''s loa beliefs?', 'Elortha no Shadra', 'Bwonsamdi', 'Hakkar', 'Shirvallah');
INSERT INTO public."Question" VALUES (713, 101, 'Which fictional English county was the setting for Thomas Hardy''s novels?', 'Wessex', 'Barsetshire', 'Fulchester', 'Ambridge');
INSERT INTO public."Question" VALUES (724, 101, 'In Touhou: Embodiment of Scarlet Devil, what song plays during Flandre Scarlet''s boss fight?', 'U.N. Owen Was Her', 'Septette for the Dead Princess', 'Flowering Night', 'Pierrot of the Star-Spangled Banner');
INSERT INTO public."Question" VALUES (734, 101, 'During the game''s development, what was the first ever created Pokemon?', 'Rhyhorn', 'Bulbasaur', 'Mew', 'Arceus');
INSERT INTO public."Question" VALUES (804, 101, 'What was Bon Iver''s debut album released in 2007?', 'For Emma, Forever Ago', 'Bon Iver, Bon Iver', '22, A Million', 'Blood Bank EP');
INSERT INTO public."Question" VALUES (807, 101, 'In the game Danganronpa: Happy Trigger Havoc, the character Aoi Asahina''s ultimate ability is what?', 'Ultimate Swimmer', 'Ultimate Detective', 'Ultimate Gambler', 'Ultimate Dancer');
INSERT INTO public."Question" VALUES (831, 101, 'Which was the first of Alfred Hitchcock''s movies to be filmed in colour?', 'Rope', 'Psycho', 'Vertigo', 'Rebecca');
INSERT INTO public."Question" VALUES (832, 101, 'In Calvin and Hobbes, what is the name of Susie''s stuffed rabbit?', 'Mr. Bun', 'Mr. Bunbun', 'Mr. Rabbit', 'Mr. Hoppy');
INSERT INTO public."Question" VALUES (915, 101, 'What was Rage Against the Machine''s debut album?', 'Rage Against the Machine', 'Evil Empire', 'Bombtrack', 'The Battle Of Los Angeles');
INSERT INTO public."Question" VALUES (921, 101, 'The ''64'' in the Nintendo-64 console refers to what?', 'The bits in the CPU architecture', 'The number of megabytes of RAM', 'Capacity of the ROM Cartridges in megabytes', 'Clock speed of the CPU in Hertz');
INSERT INTO public."Question" VALUES (926, 101, 'What is the name of the robot in the 1951 science fiction film classic ''The Day the Earth Stood Still''?', 'Gort', 'Robby', 'Colossus', 'Box');
INSERT INTO public."Question" VALUES (927, 101, 'What''s the race of Invincible''s father?', 'Viltrumite', 'Kryptonian', 'Kree', 'Irken');
INSERT INTO public."Question" VALUES (842, 101, 'Which of these is NOT a song on The Beatles'' 1968 self titled album, also known as the White album?', 'Being For The Benefit Of Mr. Kite!', 'Why Don''t We Do It in the Road?', 'Everybody''s Got Something to Hide Except Me and My Monkey', 'The Continuing Story of Bungalow Bill');
INSERT INTO public."Question" VALUES (1018, 101, 'What is Gabe Newell''s favorite class in Team Fortress 2?', 'Spy', 'Heavy', 'Medic', 'Pyro');
INSERT INTO public."Question" VALUES (1029, 101, 'What is the name of Team Fortress 2''s Heavy Weapons Guy''s minigun?', 'Sasha', 'Betty', 'Anna', 'Diana');
INSERT INTO public."Question" VALUES (1031, 101, 'What was Britney Spears'' debut single?', '...Baby One More Time', 'Oops!... I Did It Again', '(You Drive Me) Crazy', 'Toxic');
INSERT INTO public."Question" VALUES (1041, 101, 'In the original Doctor Who series (1963), fourth doctor Tom Baker''s scarf was how long?', '7 Meters', '10 Meters', '2 Meters', '5 Meters');
INSERT INTO public."Question" VALUES (741, 101, 'Where does "The Legend of Zelda: Majora''s Mask" take place?', 'Termina', 'Hyrule', 'Gysahl', 'Besaid');
INSERT INTO public."Question" VALUES (949, 101, 'What is the first track on Kanye West''s 808s & Heartbreak?', 'Say You Will', 'Welcome to Heartbreak', 'Street Lights', 'Heartless');
INSERT INTO public."Question" VALUES (1104, 101, 'What M83 was featured in Grand Theft Auto V''s radio?', 'Midnight City', 'Outro', 'Reunion', 'Wait');
INSERT INTO public."Question" VALUES (1108, 101, 'What is the name of Ruby Rose''s weapon from RWBY?', 'Crescent Rose', 'Thorned Rosebud', 'Magnhild', 'Crooked Scythe');
INSERT INTO public."Question" VALUES (1141, 101, 'How much does the ''AWP'' cost in Counter-Strike: Global Offensive?', '$4750', '$4500', '$4650', '$5000');
INSERT INTO public."Question" VALUES (120, 101, 'In the 2002 video game "Kingdom Hearts", how many Keyblades are usable?', '18', '13', '16', '15');
INSERT INTO public."Question" VALUES (125, 101, 'Which card is on the cover of the Beta rulebook of "Magic: The Gathering"?', 'Bog Wraith', 'Island', 'Rock Hydra', 'Elvish Archers');
INSERT INTO public."Question" VALUES (129, 101, '"Gimmick!" is a Japanese Famicom game that uses a sound chip expansion in the cartridge. What is it called?', 'FME-7', 'VRC7', 'VRC6', 'MMC5');
INSERT INTO public."Question" VALUES (130, 101, 'Which of the following was not an actor/actress on the American television show "Saturday Night Live" in Season 42?', 'Tina Fey', 'Mikey Day', 'Kate McKinnon', 'Sasheer Zamata');
INSERT INTO public."Question" VALUES (131, 101, 'What CoD "Deathstreak" is only featured in Call of Duty : Modern Warfare 2?', 'Copycat', ' Martrydom', 'Final Stand', 'Revenge');
INSERT INTO public."Question" VALUES (331, 101, 'What was the UK "Who Wants to be a Millionaire?" cheating scandal known as?', 'Major Fraud', 'Ingram Cheater', 'Coughing Major', 'Millionaire Crime');
INSERT INTO public."Question" VALUES (334, 101, 'Which member of the English band "The xx" released their solo album "In Colour" in 2015?', 'Jamie xx', 'Romy Madley Croft', 'Oliver Sim', 'Baria Qureshi');
INSERT INTO public."Question" VALUES (336, 101, 'Which of these characters from "SpongeBob SquarePants" is not a squid?', 'Gary', 'Orvillie', 'Squidward', 'Squidette');
INSERT INTO public."Question" VALUES (535, 101, 'What is the hardest possible difficulty in "Deus Ex: Mankind Divided"?', 'I Never Asked For This', 'Nightmare', 'Extreme', 'Guru');
INSERT INTO public."Question" VALUES (546, 101, 'What is the name of the 4-armed Chaos Witch from the 2016 video game "Battleborn"?', 'Orendi', 'Orendoo', 'Oranda', 'Randy');
INSERT INTO public."Question" VALUES (547, 101, 'In the "The Hobbit", who kills Smaug?', 'Bard', 'Bilbo Baggins', 'Gandalf the Grey', 'Frodo');
INSERT INTO public."Question" VALUES (616, 101, 'Which of these actors/actresses is NOT a part of the cast for the 2016 movie "Suicide Squad"?', 'Scarlett Johansson', 'Jared Leto', 'Will Smith', 'Margot Robbie');
INSERT INTO public."Question" VALUES (619, 101, 'Which of the following is not a prosecutor in the "Ace Attorney" video game series?', 'Jake Marshall', 'Godot', 'Miles Edgeworth', 'Jacques Portsman');
INSERT INTO public."Question" VALUES (620, 101, 'Which of these is not a wonder weapon in "Call Of Duty: Zombies"?', 'R115 Resonator', 'GKZ-45 Mk3', 'Ray Gun', 'Scavenger');
INSERT INTO public."Question" VALUES (634, 101, 'How many seasons did the Sci-Fi television show "Stargate Atlantis" have?', '5', '10', '2', '7');
INSERT INTO public."Question" VALUES (640, 101, 'Which of these is NOT a main playable character in "Grand Theft Auto V"?', 'Lamar', 'Trevor', 'Michael', 'Franklin');
INSERT INTO public."Question" VALUES (847, 101, 'What programming language was used to create the game "Minecraft"?', 'Java', 'HTML 5', 'C++', 'Python');
INSERT INTO public."Question" VALUES (848, 101, 'In board games, an additional or ammended rule that applies to a certain group or place is informally known as a "what" rule?', 'House', 'Custom', 'Extra', 'Change');
INSERT INTO public."Question" VALUES (1001, 101, 'In which year was the pen and paper RPG "Deadlands" released?', '1996', '2003', '1999', '1993');
INSERT INTO public."Question" VALUES (1004, 101, 'What year was the game "Overwatch" revealed?', '2014', '2015', '2011', '2008');
INSERT INTO public."Question" VALUES (1149, 101, 'Which game in the "Monster Hunter" series introduced the "Insect Glaive" weapon?', 'Monster Hunter 4', 'Monster Hunter Freedom', 'Monster Hunter Stories', 'Monster Hunter 2');
INSERT INTO public."Question" VALUES (1150, 101, 'How many zombies need to be killed to get the "Zombie Genocider" achievement in Dead Rising (2006)?', '53,594', '53,593', '53,595', '53,596');
INSERT INTO public."Question" VALUES (138, 101, 'Which band had hits in 1972 with the songs "Baby I''m A Want You", "Everything I Own" and "The Guitar Man"', 'Bread', 'America', 'Chicago', 'Smokie');
INSERT INTO public."Question" VALUES (230, 101, 'What was the name of Ross'' pet monkey on "Friends"?', 'Marcel', 'Jojo', 'George', 'Champ');
INSERT INTO public."Question" VALUES (237, 101, 'In the game "Undertale", who was Mettaton''s creator?', 'Alphys', 'Undyne', 'Sans', 'Asgore');
INSERT INTO public."Question" VALUES (238, 101, 'What is Everest''s favorite food in the Nickelodeon/Nick Jr. series "PAW Patrol"?', 'Liver', 'Chicken', 'Steak', 'Caribou');
INSERT INTO public."Question" VALUES (242, 101, 'In the Animal Crossing series, which flower is erroneously called the "Jacob''s Ladder"?', 'Lily of the Valley', 'Hydrangea', 'Harebell', 'Yarrow');
INSERT INTO public."Question" VALUES (244, 101, 'The 1952 musical composition 4''33", composed by prolific American composer John Cage, is mainly comprised of what sound?', 'Silence', 'Farts', 'People talking', 'Cricket chirps');
INSERT INTO public."Question" VALUES (303, 101, 'Which of these languages was NOT included in the 2016 song "Don''t Mind" by Kent Jones?', 'Portuguese', 'Japanese', 'French', 'Spanish');
INSERT INTO public."Question" VALUES (312, 101, 'In the "Jurassic Park" universe, what is the name of the island that contains InGen''s Site B?', 'Isla Sorna', 'Isla Nublar', 'Isla Pena', 'Isla Muerta');
INSERT INTO public."Question" VALUES (417, 101, 'Which Beatle wrote and sang the song "Why Don''t We Do It in the Road" after being inspired by seeing two monkeys copulating in the street?', 'Paul', 'John', 'George', 'Ringo');
INSERT INTO public."Question" VALUES (420, 101, 'Which operation in "Tom Clancy''s Rainbow Six Siege" introduced the "Skyscraper" map?', 'Red Crow', 'Velvet Shell', 'Skull Rain', 'Dust Line');
INSERT INTO public."Question" VALUES (117, 101, 'In the game series "The Legend of Zelda", what was the first 3D game?', 'Ocarina of Time', 'Majora''s Mask', 'A Link to the Past', 'The Wind Waker');
INSERT INTO public."Question" VALUES (446, 101, 'In the survival horror game, "Cry of Fear," what was the name of Simon''s close friend/potential love interest?', 'Sophie', 'Olivia', 'Jessica', 'Alice');
INSERT INTO public."Question" VALUES (527, 101, 'In the "Pikmin" games, which of the following pikmin colors lacks it''s own "Onion" nest?', 'Purple', 'Winged', 'Blue', 'Rock');
INSERT INTO public."Question" VALUES (914, 101, '"The first rule is: you don''t talk about it" is a reference to which movie?', 'Fight Club', 'The Island', 'Unthinkable', 'American Pie');
INSERT INTO public."Question" VALUES (1003, 101, 'In the game "Red Dead Redemption", what is the name of John Marston''s dog?', 'Rufus', 'Rutus', 'Finn', 'Apollo');
INSERT INTO public."Question" VALUES (1024, 101, 'In Kendrick Lamar''s 2012 album, "Good Kid, M.A.A.D City", the album''s story takes place in which city?', 'Compton', 'Detroit', 'New York', 'Baltimore');
INSERT INTO public."Question" VALUES (1042, 101, 'Who in Pulp Fiction says "No, they got the metric system there, they wouldn''t know what the f*** a Quarter Pounder is."', 'Vincent Vega', 'Jules Winnfield', 'Jimmie Dimmick', 'Butch Coolidge');
INSERT INTO public."Question" VALUES (234, 101, 'Dee from "It''s Always Sunny in Philadelphia" has dated all of the following guys EXCEPT', 'Matthew "Rickety Cricket" Mara', 'Colin the Thief', 'Ben the Soldier', 'Kevin Gallagher aka Lil'' Kevin');
INSERT INTO public."Question" VALUES (1103, 101, 'In "Overwatch," what is the hero McCree''s full name?', 'Jesse McCree', 'Jack "McCree" Morrison', 'Gabriel Reyes', 'Jamison "Deadeye" Fawkes');


--
-- TOC entry 4101 (class 2606 OID 24727)
-- Name: Category Category_pkey; Type: CONSTRAINT; Schema: public; Owner: drasi
--

ALTER TABLE ONLY public."Category"
    ADD CONSTRAINT "Category_pkey" PRIMARY KEY (id);


--
-- TOC entry 4103 (class 2606 OID 24735)
-- Name: Question Question_pkey; Type: CONSTRAINT; Schema: public; Owner: drasi
--

ALTER TABLE ONLY public."Question"
    ADD CONSTRAINT "Question_pkey" PRIMARY KEY (id);


-- Completed on 2024-03-08 11:54:35 PST

--
-- PostgreSQL database dump complete
--

