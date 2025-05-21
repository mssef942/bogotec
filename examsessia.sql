--
-- PostgreSQL database dump
--

-- Dumped from database version 15.3
-- Dumped by pg_dump version 15.3

-- Started on 2025-05-21 09:50:41

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

--
-- TOC entry 234 (class 1255 OID 105417)
-- Name: dolgnost_teacher(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.dolgnost_teacher() RETURNS character varying
    LANGUAGE sql
    AS $$select dolgnost
from teacher;$$;


ALTER FUNCTION public.dolgnost_teacher() OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 105419)
-- Name: dolgnostteacher(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.dolgnostteacher() RETURNS text
    LANGUAGE sql
    AS $$
select dolgnost from teacher
$$;


ALTER FUNCTION public.dolgnostteacher() OWNER TO postgres;

--
-- TOC entry 249 (class 1255 OID 105462)
-- Name: log_teacher_changes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_teacher_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO teacher_audit(operation, teacher_id, changed_by, new_data)
        VALUES ('INSERT', NEW.teacher_id, current_user, to_jsonb(NEW));
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO teacher_audit(operation, teacher_id, changed_by, old_data, new_data)
        VALUES ('UPDATE', NEW.teacher_id, current_user, to_jsonb(OLD), to_jsonb(NEW));
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO teacher_audit(operation, teacher_id, changed_by, old_data)
        VALUES ('DELETE', OLD.teacher_id, current_user, to_jsonb(OLD));
    END IF;
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.log_teacher_changes() OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 105406)
-- Name: name_student(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.name_student() RETURNS "char"
    LANGUAGE sql
    AS $$select name
from student;

$$;


ALTER FUNCTION public.name_student() OWNER TO postgres;

--
-- TOC entry 232 (class 1255 OID 105411)
-- Name: namestudent(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.namestudent() RETURNS name
    LANGUAGE sql
    AS $$
select name from student
$$;


ALTER FUNCTION public.namestudent() OWNER TO postgres;

--
-- TOC entry 233 (class 1255 OID 105413)
-- Name: semestr_subject(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.semestr_subject() RETURNS integer
    LANGUAGE sql
    AS $$select semestr
from subject;$$;


ALTER FUNCTION public.semestr_subject() OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 105414)
-- Name: semestrsubject(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.semestrsubject() RETURNS name
    LANGUAGE sql
    AS $$
select semestr from subject
$$;


ALTER FUNCTION public.semestrsubject() OWNER TO postgres;

--
-- TOC entry 250 (class 1255 OID 105465)
-- Name: validate_exam_date(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validate_exam_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    subject_duration INT;
BEGIN
    -- Получаем продолжительность предмета
    SELECT duration_weeks INTO subject_duration
    FROM subject
    WHERE subject_id = NEW.subject_id;
    
    -- Проверяем, что экзамен не назначен раньше окончания курса
    IF NEW.exam_date < CURRENT_DATE + (subject_duration * 7) THEN
        RAISE EXCEPTION 'Экзамен не может быть назначен раньше окончания курса';
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.validate_exam_date() OWNER TO postgres;

--
-- TOC entry 248 (class 1255 OID 105450)
-- Name: validate_grade(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validate_grade() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    max_score INT;
    exam_subject_id INT;
    student_group_id INT;
    teacher_subject_id INT;
BEGIN
    -- Получаем максимальный балл для предмета и проверяем оценку
    SELECT s.max_score, e.subject_id INTO max_score, exam_subject_id
    FROM subject s
    JOIN exams e ON s.subject_id = e.subject_id
    WHERE e.exam_id = NEW.exam_id;
    
    IF NEW.grade < 0 OR NEW.grade > max_score THEN
        RAISE EXCEPTION 'Оценка должна быть в диапазоне от 0 до %', max_score;
    END IF;
    
    -- Проверяем, что студент может получить оценку по этому предмету
    SELECT group_id INTO student_group_id FROM student WHERE student_id = NEW.student_id;
    
    SELECT subject_id INTO teacher_subject_id 
    FROM teacher 
    WHERE teacher_id = (SELECT teacher_id FROM exams WHERE exam_id = NEW.exam_id);
    
    IF exam_subject_id != teacher_subject_id THEN
        RAISE EXCEPTION 'Преподаватель не ведет этот предмет';
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.validate_grade() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 80742)
-- Name: exams; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.exams (
    "ExamDATE" date NOT NULL,
    "ExamTime" date NOT NULL,
    "Auditorium" character varying(50) NOT NULL,
    id_exam integer NOT NULL,
    id_subject integer NOT NULL
);


ALTER TABLE public.exams OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 80753)
-- Name: Exams_id_exam_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Exams_id_exam_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Exams_id_exam_seq" OWNER TO postgres;

--
-- TOC entry 3416 (class 0 OID 0)
-- Dependencies: 222
-- Name: Exams_id_exam_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Exams_id_exam_seq" OWNED BY public.exams.id_exam;


--
-- TOC entry 221 (class 1259 OID 80749)
-- Name: grades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grades (
    ocenka integer NOT NULL,
    "IssauDate" date NOT NULL,
    id_student integer,
    id_exam integer NOT NULL,
    id_grade integer NOT NULL
);


ALTER TABLE public.grades OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 80765)
-- Name: Grades_id_grade_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Grades_id_grade_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Grades_id_grade_seq" OWNER TO postgres;

--
-- TOC entry 3417 (class 0 OID 0)
-- Dependencies: 223
-- Name: Grades_id_grade_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Grades_id_grade_seq" OWNED BY public.grades.id_grade;


--
-- TOC entry 228 (class 1259 OID 97167)
-- Name: admins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admins (
    id integer NOT NULL,
    username character varying(100) NOT NULL,
    password character varying(100) NOT NULL
);


ALTER TABLE public.admins OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 97166)
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.admins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.admins_id_seq OWNER TO postgres;

--
-- TOC entry 3418 (class 0 OID 0)
-- Dependencies: 227
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.admins_id_seq OWNED BY public.admins.id;


--
-- TOC entry 215 (class 1259 OID 80716)
-- Name: student; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "group" character varying(255) NOT NULL,
    "Birthdate" date NOT NULL,
    visible boolean DEFAULT true NOT NULL
);


ALTER TABLE public.student OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 80715)
-- Name: student_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.student_id_seq OWNER TO postgres;

--
-- TOC entry 3419 (class 0 OID 0)
-- Dependencies: 214
-- Name: student_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.student_id_seq OWNED BY public.student.id;


--
-- TOC entry 225 (class 1259 OID 97107)
-- Name: studenta; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.studenta AS
 SELECT student.id,
    student.*::public.student AS student
   FROM public.student
  WHERE (student.visible IS TRUE);


ALTER TABLE public.studenta OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 97103)
-- Name: studenti; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.studenti AS
 SELECT student.id,
    student.*::public.student AS student
   FROM public.student
  WHERE (student.visible IS TRUE);


ALTER TABLE public.studenti OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 97111)
-- Name: studentt; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.studentt AS
 SELECT student.id,
    student.*::public.student AS student
   FROM public.student
  WHERE (student.visible IS TRUE);


ALTER TABLE public.studentt OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 80735)
-- Name: subject; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subject (
    id integer NOT NULL,
    "Name" character varying(255) NOT NULL,
    semestr integer NOT NULL,
    visible boolean DEFAULT true NOT NULL
);


ALTER TABLE public.subject OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 80734)
-- Name: subject_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.subject_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.subject_id_seq OWNER TO postgres;

--
-- TOC entry 3420 (class 0 OID 0)
-- Dependencies: 218
-- Name: subject_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.subject_id_seq OWNED BY public.subject.id;


--
-- TOC entry 217 (class 1259 OID 80728)
-- Name: teacher; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teacher (
    id integer NOT NULL,
    fullname character varying(255) NOT NULL,
    dolgnost character varying(25) NOT NULL
);


ALTER TABLE public.teacher OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 105453)
-- Name: teacher_audit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teacher_audit (
    audit_id integer NOT NULL,
    operation character varying(10) NOT NULL,
    teacher_id integer NOT NULL,
    changed_by character varying(100) NOT NULL,
    change_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    old_data jsonb,
    new_data jsonb
);


ALTER TABLE public.teacher_audit OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 105452)
-- Name: teacher_audit_audit_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.teacher_audit_audit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.teacher_audit_audit_id_seq OWNER TO postgres;

--
-- TOC entry 3421 (class 0 OID 0)
-- Dependencies: 229
-- Name: teacher_audit_audit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.teacher_audit_audit_id_seq OWNED BY public.teacher_audit.audit_id;


--
-- TOC entry 216 (class 1259 OID 80727)
-- Name: teacher_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.teacher_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.teacher_id_seq OWNER TO postgres;

--
-- TOC entry 3422 (class 0 OID 0)
-- Dependencies: 216
-- Name: teacher_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.teacher_id_seq OWNED BY public.teacher.id;


--
-- TOC entry 3231 (class 2604 OID 97170)
-- Name: admins id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins ALTER COLUMN id SET DEFAULT nextval('public.admins_id_seq'::regclass);


--
-- TOC entry 3229 (class 2604 OID 80754)
-- Name: exams id_exam; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exams ALTER COLUMN id_exam SET DEFAULT nextval('public."Exams_id_exam_seq"'::regclass);


--
-- TOC entry 3230 (class 2604 OID 80766)
-- Name: grades id_grade; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades ALTER COLUMN id_grade SET DEFAULT nextval('public."Grades_id_grade_seq"'::regclass);


--
-- TOC entry 3224 (class 2604 OID 80719)
-- Name: student id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student ALTER COLUMN id SET DEFAULT nextval('public.student_id_seq'::regclass);


--
-- TOC entry 3227 (class 2604 OID 80738)
-- Name: subject id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject ALTER COLUMN id SET DEFAULT nextval('public.subject_id_seq'::regclass);


--
-- TOC entry 3226 (class 2604 OID 80731)
-- Name: teacher id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher ALTER COLUMN id SET DEFAULT nextval('public.teacher_id_seq'::regclass);


--
-- TOC entry 3232 (class 2604 OID 105456)
-- Name: teacher_audit audit_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_audit ALTER COLUMN audit_id SET DEFAULT nextval('public.teacher_audit_audit_id_seq'::regclass);


--
-- TOC entry 3408 (class 0 OID 97167)
-- Dependencies: 228
-- Data for Name: admins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admins (id, username, password) FROM stdin;
1	admin	0000
\.


--
-- TOC entry 3403 (class 0 OID 80742)
-- Dependencies: 220
-- Data for Name: exams; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.exams ("ExamDATE", "ExamTime", "Auditorium", id_exam, id_subject) FROM stdin;
2025-06-10	2025-06-10	5	5	13
2025-12-18	2025-12-18	36	4	11
2025-12-15	2025-12-15	12	3	521
2025-06-13	2025-06-13	52\n	2	123
2025-06-15	2025-06-16	42\n	1	43
\.


--
-- TOC entry 3404 (class 0 OID 80749)
-- Dependencies: 221
-- Data for Name: grades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.grades (ocenka, "IssauDate", id_student, id_exam, id_grade) FROM stdin;
3	2025-12-12	17	52	14
4	2025-06-20	12	42	15
2	2025-06-15	13	342	16
5	2025-12-10	16	444	17
4	2025-06-10	15	123	18
\.


--
-- TOC entry 3398 (class 0 OID 80716)
-- Dependencies: 215
-- Data for Name: student; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student (id, name, "group", "Birthdate", visible) FROM stdin;
1	Симоняка Сергей Сергеевич	П-24	2006-06-02	t
2	Бобрышев Алексей Денисович	П-12	2007-03-19	t
3	Ефименок Максим Александрович	П-34	2007-10-10	t
4	Игнатьев Юрий Николаевич	П-42	2007-10-24	t
5	Казаков Денис  Денисович	П-12	2007-01-01	t
\.


--
-- TOC entry 3402 (class 0 OID 80735)
-- Dependencies: 219
-- Data for Name: subject; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subject (id, "Name", semestr, visible) FROM stdin;
2	Алексей	5	t
3	Денис	1	t
4	Максим	3	t
5	Сергей	4	t
6	Юра	2	t
\.


--
-- TOC entry 3400 (class 0 OID 80728)
-- Dependencies: 217
-- Data for Name: teacher; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teacher (id, fullname, dolgnost) FROM stdin;
2	Нестеренко Татьяна Владимировна	Преподаватель
3	Рогова Татьяна Николваевна	Психолог
4	Мусаев Заур Интигамович	Зам воспитательной работы
5	Чарушина Елена Владимировна	Заместитель директора
6	Акимов Иван Акимович	Директор
\.


--
-- TOC entry 3410 (class 0 OID 105453)
-- Dependencies: 230
-- Data for Name: teacher_audit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teacher_audit (audit_id, operation, teacher_id, changed_by, change_time, old_data, new_data) FROM stdin;
\.


--
-- TOC entry 3423 (class 0 OID 0)
-- Dependencies: 222
-- Name: Exams_id_exam_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Exams_id_exam_seq"', 2, true);


--
-- TOC entry 3424 (class 0 OID 0)
-- Dependencies: 223
-- Name: Grades_id_grade_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Grades_id_grade_seq"', 18, true);


--
-- TOC entry 3425 (class 0 OID 0)
-- Dependencies: 227
-- Name: admins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admins_id_seq', 1, true);


--
-- TOC entry 3426 (class 0 OID 0)
-- Dependencies: 214
-- Name: student_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_id_seq', 9, true);


--
-- TOC entry 3427 (class 0 OID 0)
-- Dependencies: 218
-- Name: subject_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.subject_id_seq', 6, true);


--
-- TOC entry 3428 (class 0 OID 0)
-- Dependencies: 229
-- Name: teacher_audit_audit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.teacher_audit_audit_id_seq', 1, false);


--
-- TOC entry 3429 (class 0 OID 0)
-- Dependencies: 216
-- Name: teacher_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.teacher_id_seq', 6, true);


--
-- TOC entry 3241 (class 2606 OID 80759)
-- Name: exams Exams_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exams
    ADD CONSTRAINT "Exams_pkey" PRIMARY KEY (id_exam);


--
-- TOC entry 3243 (class 2606 OID 88907)
-- Name: grades Grades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT "Grades_pkey" PRIMARY KEY (id_grade);


--
-- TOC entry 3245 (class 2606 OID 97172)
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- TOC entry 3235 (class 2606 OID 80723)
-- Name: student student_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_pkey PRIMARY KEY (id);


--
-- TOC entry 3239 (class 2606 OID 80740)
-- Name: subject subject_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject
    ADD CONSTRAINT subject_pkey PRIMARY KEY (id);


--
-- TOC entry 3247 (class 2606 OID 105461)
-- Name: teacher_audit teacher_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_audit
    ADD CONSTRAINT teacher_audit_pkey PRIMARY KEY (audit_id);


--
-- TOC entry 3237 (class 2606 OID 80733)
-- Name: teacher teacher_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher
    ADD CONSTRAINT teacher_pkey PRIMARY KEY (id);


--
-- TOC entry 3396 (class 2618 OID 97122)
-- Name: subject delete_subject; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE delete_subject AS
    ON DELETE TO public.subject DO INSTEAD  UPDATE public.subject SET visible = false
  WHERE (subject.id = old.id);


--
-- TOC entry 3248 (class 2620 OID 105463)
-- Name: teacher tr_log_teacher_changes; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_log_teacher_changes AFTER INSERT OR DELETE OR UPDATE ON public.teacher FOR EACH ROW EXECUTE FUNCTION public.log_teacher_changes();


--
-- TOC entry 3249 (class 2620 OID 105466)
-- Name: exams tr_validate_exam_date; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_validate_exam_date BEFORE INSERT OR UPDATE ON public.exams FOR EACH ROW EXECUTE FUNCTION public.validate_exam_date();


--
-- TOC entry 3250 (class 2620 OID 105451)
-- Name: grades tr_validate_grade; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_validate_grade BEFORE INSERT OR UPDATE ON public.grades FOR EACH ROW EXECUTE FUNCTION public.validate_grade();


-- Completed on 2025-05-21 09:50:41

--
-- PostgreSQL database dump complete
--

