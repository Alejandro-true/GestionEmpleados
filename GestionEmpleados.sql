--
-- PostgreSQL database dump
--

\restrict vMXRLVybamCQSaRaaOlDz9kdyc28xPo1FbgP5O0uOh1DBd2itho3MOWNXYspZjR

-- Dumped from database version 15.18 (Debian 15.18-1.pgdg13+1)
-- Dumped by pg_dump version 15.18 (Debian 15.18-1.pgdg13+1)

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
-- Name: fn_ActivarUsuario(integer); Type: FUNCTION; Schema: public; Owner: renind
--

CREATE FUNCTION public."fn_ActivarUsuario"(p_usuidusuario integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

BEGIN

    IF NOT EXISTS (

        SELECT 1 FROM public."Usuario"

        WHERE "UsuIdUsuario" = p_UsuIdUsuario AND "UsuEstado" = 'Inactivo'

    ) THEN

        RETURN FALSE;

    END IF;



    UPDATE public."Usuario"

    SET "UsuEstado" = 'Activo'

    WHERE "UsuIdUsuario" = p_UsuIdUsuario;



    RETURN TRUE;

END;

$$;


ALTER FUNCTION public."fn_ActivarUsuario"(p_usuidusuario integer) OWNER TO renind;

--
-- Name: fn_ActualizarSalarioArea(integer, numeric, character varying); Type: FUNCTION; Schema: public; Owner: renind
--

CREATE FUNCTION public."fn_ActualizarSalarioArea"(p_areidarea integer, p_nuevosalario numeric, p_usuario character varying DEFAULT 'sistema'::character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

DECLARE

    v_MontoAnterior numeric(7,2);

    v_NombreArea    character varying(50);

BEGIN

    SELECT "AreSalario", "AreNombreArea"

    INTO v_MontoAnterior, v_NombreArea

    FROM public."Area"

    WHERE "AreIdArea" = p_AreIdArea;



    IF NOT FOUND THEN

        RETURN FALSE;

    END IF;



    -- Actualizar salario

    UPDATE public."Area"

    SET "AreSalario" = p_NuevoSalario

    WHERE "AreIdArea" = p_AreIdArea;



    -- Registrar en auditor??a

    INSERT INTO public."AuditoriaLog" (

        "AudUsuario", "AudAreIdArea", "AudNombreArea",

        "AudMontoAnterior", "AudMontoNuevo"

    )

    VALUES (

        p_Usuario, p_AreIdArea, v_NombreArea,

        v_MontoAnterior, p_NuevoSalario

    );



    RETURN TRUE;

END;

$$;


ALTER FUNCTION public."fn_ActualizarSalarioArea"(p_areidarea integer, p_nuevosalario numeric, p_usuario character varying) OWNER TO renind;

--
-- Name: fn_AutenticarUsuario(character varying, character varying); Type: FUNCTION; Schema: public; Owner: renind
--

CREATE FUNCTION public."fn_AutenticarUsuario"(p_nombreusuario character varying, p_contrasenia character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$

DECLARE

    v_NombreRol character varying(20);

    v_Estado    character varying(10);

BEGIN

    SELECT r."RolNombreRol", u."UsuEstado"

    INTO v_NombreRol, v_Estado

    FROM public."Usuario" u

    JOIN public."Rol" r ON u."UsuIdRol" = r."RolIdRol"

    WHERE u."UsuNombreUsuario" = p_nombreusuario

      AND u."UsuContrasenia"   = p_contrasenia;



    -- Credenciales incorrectas

    IF v_NombreRol IS NULL THEN

        RETURN NULL;

    END IF;



    -- Cuenta inactiva

    IF v_Estado = 'Inactivo' THEN

        RETURN 'Inactivo';

    END IF;



    RETURN v_NombreRol;

END;

$$;


ALTER FUNCTION public."fn_AutenticarUsuario"(p_nombreusuario character varying, p_contrasenia character varying) OWNER TO renind;

--
-- Name: fn_CalcularAntiguedad(character varying); Type: FUNCTION; Schema: public; Owner: renind
--

CREATE FUNCTION public."fn_CalcularAntiguedad"(p_empcodigo character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

DECLARE

    v_Antiguedad integer;

BEGIN

    SELECT EXTRACT(YEAR FROM age(CURRENT_DATE, "EmpFechaIngreso")) INTO v_Antiguedad

    FROM "Empleado"

    WHERE "EmpCodigo" = p_EmpCodigo;



    RETURN COALESCE(v_Antiguedad, 0);

END;

$$;


ALTER FUNCTION public."fn_CalcularAntiguedad"(p_empcodigo character varying) OWNER TO renind;

--
-- Name: fn_CalcularCts(character varying, integer); Type: FUNCTION; Schema: public; Owner: renind
--

CREATE FUNCTION public."fn_CalcularCts"(p_empcodigo character varying, p_mes integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$

DECLARE

    v_Salario numeric(7,2);

BEGIN

    IF p_Mes NOT IN (5, 11) THEN

        RETURN 0.00;

    END IF;



    v_Salario := public."fn_ObtenerSalarioEmpleado"(p_EmpCodigo);  -- nombre correcto

    RETURN ROUND(v_Salario / 2, 2);

END;

$$;


ALTER FUNCTION public."fn_CalcularCts"(p_empcodigo character varying, p_mes integer) OWNER TO renind;

--
-- Name: fn_CalcularEdad(character varying); Type: FUNCTION; Schema: public; Owner: renind
--

CREATE FUNCTION public."fn_CalcularEdad"(p_empcodigo character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

DECLARE

    v_Edad integer;

BEGIN

    SELECT EXTRACT(YEAR FROM age(CURRENT_DATE, u."UsuFechaNacimiento")) INTO v_Edad

    FROM "Empleado" e

    JOIN "Usuario" u ON e."EmpIdUsuario" = u."UsuIdUsuario"

    WHERE e."EmpCodigo" = p_EmpCodigo;



    RETURN COALESCE(v_Edad, 0);

END;

$$;


ALTER FUNCTION public."fn_CalcularEdad"(p_empcodigo character varying) OWNER TO renind;

--
-- Name: fn_CalcularGratificacion(integer); Type: FUNCTION; Schema: public; Owner: renind
--

CREATE FUNCTION public."fn_CalcularGratificacion"(p_mes integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$

DECLARE

    v_Monto numeric(7,2);

BEGIN

    SELECT "GraMonto" INTO v_Monto

    FROM public."Gratificacion"

    WHERE "GraMes" = p_mes;



    RETURN COALESCE(v_Monto, 0.00);

END;

$$;


ALTER FUNCTION public."fn_CalcularGratificacion"(p_mes integer) OWNER TO renind;

--
-- Name: fn_CerrarContratoAnterior(); Type: FUNCTION; Schema: public; Owner: renind
--

CREATE FUNCTION public."fn_CerrarContratoAnterior"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

    -- Busca si el empleado tiene alg??n contrato activo previo

    -- y lo cierra con fechafin = fecha inicio del nuevo contrato

    UPDATE public."Contrato"

    SET

        "ConEstado"        = 'Finalizado',

        "ConFechaFin" = NEW."ConFechaInicio" - INTERVAL '1 day'

    WHERE

        "ConCodEmpleado" = NEW."ConCodEmpleado"

        AND "ConEstado"        = 'Activo'

        AND "ConIdContrato" <> NEW."ConIdContrato";



    RETURN NEW;

END;

$$;


ALTER FUNCTION public."fn_CerrarContratoAnterior"() OWNER TO renind;

--
-- Name: fn_DesactivarPorInactividad(integer); Type: FUNCTION; Schema: public; Owner: renind
--

CREATE FUNCTION public."fn_DesactivarPorInactividad"(p_anios integer DEFAULT 5) RETURNS integer
    LANGUAGE plpgsql
    AS $$

DECLARE

    v_Contador integer := 0;

    v_Fecha    date;

BEGIN

    -- Fecha l??mite: hoy menos los a??os indicados

    v_Fecha := CURRENT_DATE - (p_Anios || ' years')::interval;



    UPDATE public."Usuario" u

    SET "UsuEstado" = 'Inactivo'

    FROM public."Empleado" e

    WHERE e."EmpIdUsuario" = u."UsuIdUsuario"

      AND u."UsuEstado"    = 'Activo'

      -- No tiene ning??n contrato activo actualmente

      AND NOT EXISTS (

          SELECT 1 FROM public."Contrato" c

          WHERE c."ConCodEmpleado" = e."EmpCodigo"

            AND c."ConEstado"      = 'Activo'

      )

      -- Y su ??ltimo contrato termin?? hace m??s de p_Anios a??os

      AND (

          SELECT MAX(c2."ConFechaFin")

          FROM public."Contrato" c2

          WHERE c2."ConCodEmpleado" = e."EmpCodigo"

      ) < v_Fecha;



    GET DIAGNOSTICS v_Contador = ROW_COUNT;

    RETURN v_Contador;

END;

$$;


ALTER FUNCTION public."fn_DesactivarPorInactividad"(p_anios integer) OWNER TO renind;

--
-- Name: fn_DesactivarUsuario(integer); Type: FUNCTION; Schema: public; Owner: renind
--

CREATE FUNCTION public."fn_DesactivarUsuario"(p_usuidusuario integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

BEGIN

    IF NOT EXISTS (

        SELECT 1 FROM public."Usuario"

        WHERE "UsuIdUsuario" = p_UsuIdUsuario AND "UsuEstado" = 'Activo'

    ) THEN

        RETURN FALSE;

    END IF;



    UPDATE public."Usuario"

    SET "UsuEstado" = 'Inactivo'

    WHERE "UsuIdUsuario" = p_UsuIdUsuario;



    RETURN TRUE;

END;

$$;


ALTER FUNCTION public."fn_DesactivarUsuario"(p_usuidusuario integer) OWNER TO renind;

--
-- Name: fn_FinalizarContrato(integer, date); Type: FUNCTION; Schema: public; Owner: renind
--

CREATE FUNCTION public."fn_FinalizarContrato"(p_conidcontrato integer, p_fechafin date DEFAULT CURRENT_DATE) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

BEGIN

    IF NOT EXISTS (

        SELECT 1 FROM public."Contrato"

        WHERE "ConIdContrato" = p_conidcontrato AND "ConEstado" = 'Activo'

    ) THEN

        RETURN FALSE;

    END IF;



    UPDATE public."Contrato"

    SET "ConFechaFin" = p_fechafin,

        "ConEstado"   = 'Finalizado'

    WHERE "ConIdContrato" = p_conidcontrato;



    RETURN TRUE;

END;

$$;


ALTER FUNCTION public."fn_FinalizarContrato"(p_conidcontrato integer, p_fechafin date) OWNER TO renind;

--
-- Name: fn_GenerarBoleta(character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: renind
--

CREATE FUNCTION public."fn_GenerarBoleta"(p_empcodigo character varying, p_anio integer, p_mes integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$

DECLARE

    v_Salario       numeric(7,2);

    v_Gratificacion numeric(7,2);

    v_NombreGrat    character varying(50);

    v_CTS           numeric(7,2);

    v_Total         numeric(7,2);

    v_Periodo       character varying(20);

    v_IdBoleta      integer;

    v_NombreMes     character varying(20);

BEGIN

    v_Salario := public."fn_ObtenerSalarioEmpleado"(p_empcodigo);

    IF v_Salario = 0 THEN

        RAISE EXCEPTION 'Empleado % no encontrado o sin ├írea asignada', p_empcodigo;

    END IF;



    SELECT "GraMonto", "GraNombre"

    INTO v_Gratificacion, v_NombreGrat

    FROM public."Gratificacion"

    WHERE "GraMes" = p_mes;



    v_Gratificacion := COALESCE(v_Gratificacion, 0.00);

    v_CTS   := public."fn_CalcularCts"(p_empcodigo, p_mes);

    v_Total := v_Salario + v_Gratificacion + v_CTS;



    v_NombreMes := CASE p_mes

        WHEN 1  THEN 'Enero'     WHEN 2  THEN 'Febrero'

        WHEN 3  THEN 'Marzo'     WHEN 4  THEN 'Abril'

        WHEN 5  THEN 'Mayo'      WHEN 6  THEN 'Junio'

        WHEN 7  THEN 'Julio'     WHEN 8  THEN 'Agosto'

        WHEN 9  THEN 'Setiembre' WHEN 10 THEN 'Octubre'

        WHEN 11 THEN 'Noviembre' WHEN 12 THEN 'Diciembre'

        ELSE 'Desconocido'

    END;



    v_Periodo := v_NombreMes || ' ' || p_anio::text;



    INSERT INTO public."Boleta" ("BolPeriodo","BolFechaEmision","BolTotal","BolCodEmpleado")

    VALUES (

        v_Periodo,

        (DATE_TRUNC('month', MAKE_DATE(p_anio, p_mes, 1)) + INTERVAL '1 month - 1 day')::date,

        v_Total,

        p_empcodigo

    )

    RETURNING "BolIdBoleta" INTO v_IdBoleta;



    INSERT INTO public."DetalleBoleta" ("DetConcepto","DetMonto","DetIdBoleta")

    VALUES ('Salario B├ísico Mensual', v_Salario, v_IdBoleta);



    IF v_Gratificacion > 0 THEN

        INSERT INTO public."DetalleBoleta" ("DetConcepto","DetMonto","DetIdBoleta")

        VALUES (v_NombreGrat, v_Gratificacion, v_IdBoleta);

    END IF;



    IF v_CTS > 0 THEN

        INSERT INTO public."DetalleBoleta" ("DetConcepto","DetMonto","DetIdBoleta")

        VALUES ('CTS - ' || v_NombreMes, v_CTS, v_IdBoleta);

    END IF;



    RETURN v_IdBoleta;

END;

$$;


ALTER FUNCTION public."fn_GenerarBoleta"(p_empcodigo character varying, p_anio integer, p_mes integer) OWNER TO renind;

--
-- Name: fn_LimpiarDatos(); Type: FUNCTION; Schema: public; Owner: renind
--

CREATE FUNCTION public."fn_LimpiarDatos"() RETURNS void
    LANGUAGE plpgsql
    AS $$

BEGIN

    -- TRUNCATE vac??a las tablas much??simo m??s r??pido que un DELETE.

    -- RESTART IDENTITY reinicia los contadores (id 1, 2, 3...).

    -- CASCADE fuerza el borrado respetando las llaves for??neas.

    TRUNCATE TABLE 

        "DetalleBoleta", 

        "Boleta", 

        "Contrato", 

        "Empleado", 

        "Usuario", 

        "Modalidad", 

        "Jornada", 

        "Area", 

        "Genero", 

        "Rol",

		"Gratificacion",

		"AuditoriaLog"

    RESTART IDENTITY CASCADE;

END;

$$;


ALTER FUNCTION public."fn_LimpiarDatos"() OWNER TO renind;

--
-- Name: fn_ObtenerSalarioEmpleado(character varying); Type: FUNCTION; Schema: public; Owner: renind
--

CREATE FUNCTION public."fn_ObtenerSalarioEmpleado"(p_empcodigo character varying) RETURNS numeric
    LANGUAGE plpgsql
    AS $$

DECLARE

    v_Salario numeric(7,2);

BEGIN

    SELECT a."AreSalario"

    INTO v_Salario

    FROM public."Empleado" e

    JOIN public."Area" a ON e."EmpIdArea" = a."AreIdArea"

    WHERE e."EmpCodigo" = p_EmpCodigo;



    RETURN COALESCE(v_Salario, 0);

END;

$$;


ALTER FUNCTION public."fn_ObtenerSalarioEmpleado"(p_empcodigo character varying) OWNER TO renind;

--
-- Name: fn_VerBoletasEmpleado(character varying); Type: FUNCTION; Schema: public; Owner: renind
--

CREATE FUNCTION public."fn_VerBoletasEmpleado"(p_empcodigo character varying) RETURNS TABLE("IdBoleta" integer, "Periodo" character varying, "FechaEmision" date, "Concepto" character varying, "Monto" numeric, "TotalBoleta" numeric)
    LANGUAGE sql
    AS $$

    SELECT

        "IdBoleta", "Periodo", "FechaEmision",

        "Concepto", "Monto",   "TotalBoleta"

    FROM public."vw_BoletaResumen"

    WHERE "CodEmpleado" = p_EmpCodigo;

$$;


ALTER FUNCTION public."fn_VerBoletasEmpleado"(p_empcodigo character varying) OWNER TO renind;

--
-- Name: fn_VerEmpleado(character varying); Type: FUNCTION; Schema: public; Owner: renind
--

CREATE FUNCTION public."fn_VerEmpleado"(p_empcodigo character varying) RETURNS TABLE("Codigo" character varying, "NombreCompleto" text, "DNI" character varying, "Genero" character varying, "Email" character varying, "FechaNacimiento" date, "Edad" integer, "Area" character varying, "Salario" numeric, "FechaIngreso" date, "AntiguedadAnios" integer, "Rol" character varying, "Usuario" character varying, "Estado" character varying)
    LANGUAGE sql
    AS $$

    SELECT * FROM public."vw_EmpleadoCompleto"

    WHERE "Codigo" = p_empcodigo;

$$;


ALTER FUNCTION public."fn_VerEmpleado"(p_empcodigo character varying) OWNER TO renind;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Area; Type: TABLE; Schema: public; Owner: renind
--

CREATE TABLE public."Area" (
    "AreIdArea" integer NOT NULL,
    "AreNombreArea" character varying(50) NOT NULL,
    "AreSalario" numeric(7,2) NOT NULL
);


ALTER TABLE public."Area" OWNER TO renind;

--
-- Name: Area_AreIdArea_seq; Type: SEQUENCE; Schema: public; Owner: renind
--

ALTER TABLE public."Area" ALTER COLUMN "AreIdArea" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."Area_AreIdArea_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: AuditoriaLog; Type: TABLE; Schema: public; Owner: renind
--

CREATE TABLE public."AuditoriaLog" (
    "AudIdLog" integer NOT NULL,
    "AudFecha" timestamp without time zone DEFAULT now() NOT NULL,
    "AudUsuario" character varying(50) NOT NULL,
    "AudAreIdArea" integer NOT NULL,
    "AudNombreArea" character varying(50) NOT NULL,
    "AudMontoAnterior" numeric(7,2) NOT NULL,
    "AudMontoNuevo" numeric(7,2) NOT NULL
);


ALTER TABLE public."AuditoriaLog" OWNER TO renind;

--
-- Name: AuditoriaLog_AudIdLog_seq; Type: SEQUENCE; Schema: public; Owner: renind
--

ALTER TABLE public."AuditoriaLog" ALTER COLUMN "AudIdLog" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."AuditoriaLog_AudIdLog_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Boleta; Type: TABLE; Schema: public; Owner: renind
--

CREATE TABLE public."Boleta" (
    "BolIdBoleta" integer NOT NULL,
    "BolPeriodo" character varying(20) NOT NULL,
    "BolFechaEmision" date NOT NULL,
    "BolTotal" numeric(7,2) NOT NULL,
    "BolCodEmpleado" character varying(8)
);


ALTER TABLE public."Boleta" OWNER TO renind;

--
-- Name: Boleta_BolIdBoleta_seq; Type: SEQUENCE; Schema: public; Owner: renind
--

ALTER TABLE public."Boleta" ALTER COLUMN "BolIdBoleta" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."Boleta_BolIdBoleta_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Contrato; Type: TABLE; Schema: public; Owner: renind
--

CREATE TABLE public."Contrato" (
    "ConIdContrato" integer NOT NULL,
    "ConFechaInicio" date NOT NULL,
    "ConFechaFin" date,
    "ConIdJornada" integer,
    "ConIdModalidad" integer,
    "ConCodEmpleado" character varying(8),
    "ConEstado" character varying(20) DEFAULT 'Activo'::character varying,
    CONSTRAINT "Contrato_estado_check" CHECK ((("ConEstado")::text = ANY (ARRAY[('Activo'::character varying)::text, ('Finalizado'::character varying)::text, ('Anulado'::character varying)::text]))),
    CONSTRAINT contrato_fechas_check CHECK ((("ConFechaFin" IS NULL) OR ("ConFechaFin" > "ConFechaInicio")))
);


ALTER TABLE public."Contrato" OWNER TO renind;

--
-- Name: Contrato_ConIdContrato_seq; Type: SEQUENCE; Schema: public; Owner: renind
--

ALTER TABLE public."Contrato" ALTER COLUMN "ConIdContrato" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."Contrato_ConIdContrato_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: DetalleBoleta; Type: TABLE; Schema: public; Owner: renind
--

CREATE TABLE public."DetalleBoleta" (
    "DetIdDetalle" integer NOT NULL,
    "DetConcepto" character varying(255) NOT NULL,
    "DetMonto" numeric(7,2) NOT NULL,
    "DetIdBoleta" integer
);


ALTER TABLE public."DetalleBoleta" OWNER TO renind;

--
-- Name: DetalleBoleta_DetIdDetalle_seq; Type: SEQUENCE; Schema: public; Owner: renind
--

ALTER TABLE public."DetalleBoleta" ALTER COLUMN "DetIdDetalle" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."DetalleBoleta_DetIdDetalle_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Empleado; Type: TABLE; Schema: public; Owner: renind
--

CREATE TABLE public."Empleado" (
    "EmpCodigo" character varying(8) NOT NULL,
    "EmpFechaIngreso" date NOT NULL,
    "EmpIdUsuario" integer NOT NULL,
    "EmpIdArea" integer
);


ALTER TABLE public."Empleado" OWNER TO renind;

--
-- Name: Genero; Type: TABLE; Schema: public; Owner: renind
--

CREATE TABLE public."Genero" (
    "GenIdGenero" integer NOT NULL,
    "GenNombreGenero" character varying(20) NOT NULL
);


ALTER TABLE public."Genero" OWNER TO renind;

--
-- Name: Genero_GenIdGenero_seq; Type: SEQUENCE; Schema: public; Owner: renind
--

ALTER TABLE public."Genero" ALTER COLUMN "GenIdGenero" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."Genero_GenIdGenero_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Gratificacion; Type: TABLE; Schema: public; Owner: renind
--

CREATE TABLE public."Gratificacion" (
    "GraIdGratificacion" integer NOT NULL,
    "GraMes" integer NOT NULL,
    "GraNombre" character varying(50) NOT NULL,
    "GraMonto" numeric(7,2) NOT NULL,
    CONSTRAINT "Gratificacion_mes_check" CHECK ((("GraMes" >= 1) AND ("GraMes" <= 12)))
);


ALTER TABLE public."Gratificacion" OWNER TO renind;

--
-- Name: Gratificacion_GraIdGratificacion_seq; Type: SEQUENCE; Schema: public; Owner: renind
--

ALTER TABLE public."Gratificacion" ALTER COLUMN "GraIdGratificacion" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."Gratificacion_GraIdGratificacion_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Jornada; Type: TABLE; Schema: public; Owner: renind
--

CREATE TABLE public."Jornada" (
    "JorIdJornada" integer NOT NULL,
    "JorTipo" character varying(20) NOT NULL
);


ALTER TABLE public."Jornada" OWNER TO renind;

--
-- Name: Jornada_JorIdJornada_seq; Type: SEQUENCE; Schema: public; Owner: renind
--

ALTER TABLE public."Jornada" ALTER COLUMN "JorIdJornada" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."Jornada_JorIdJornada_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Modalidad; Type: TABLE; Schema: public; Owner: renind
--

CREATE TABLE public."Modalidad" (
    "ModIdModalidad" integer NOT NULL,
    "ModTipo" character varying(20) NOT NULL
);


ALTER TABLE public."Modalidad" OWNER TO renind;

--
-- Name: Modalidad_ModIdModalidad_seq; Type: SEQUENCE; Schema: public; Owner: renind
--

ALTER TABLE public."Modalidad" ALTER COLUMN "ModIdModalidad" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."Modalidad_ModIdModalidad_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Rol; Type: TABLE; Schema: public; Owner: renind
--

CREATE TABLE public."Rol" (
    "RolIdRol" integer NOT NULL,
    "RolNombreRol" character varying(20) NOT NULL
);


ALTER TABLE public."Rol" OWNER TO renind;

--
-- Name: Rol_RolIdRol_seq; Type: SEQUENCE; Schema: public; Owner: renind
--

ALTER TABLE public."Rol" ALTER COLUMN "RolIdRol" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."Rol_RolIdRol_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Usuario; Type: TABLE; Schema: public; Owner: renind
--

CREATE TABLE public."Usuario" (
    "UsuIdUsuario" integer NOT NULL,
    "UsuNombreUsuario" character varying(50) NOT NULL,
    "UsuContrasenia" character varying(50) NOT NULL,
    "UsuDni" character varying(8) NOT NULL,
    "UsuNombre" character varying(50) NOT NULL,
    "UsuApellidoPaterno" character varying(20) NOT NULL,
    "UsuApellidoMaterno" character varying(20) NOT NULL,
    "UsuEmail" character varying(50) NOT NULL,
    "UsuFechaNacimiento" date NOT NULL,
    "UsuIdGenero" integer,
    "UsuIdRol" integer,
    "UsuEstado" character varying(10) DEFAULT 'Activo'::character varying NOT NULL,
    CONSTRAINT "Usuario_UsuDni_check" CHECK ((("UsuDni")::text ~ '^[0-9]{8}$'::text)),
    CONSTRAINT "Usuario_UsuEstado_check" CHECK ((("UsuEstado")::text = ANY (ARRAY[('Activo'::character varying)::text, ('Inactivo'::character varying)::text]))),
    CONSTRAINT usuario_email_check CHECK ((("UsuEmail")::text ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'::text))
);


ALTER TABLE public."Usuario" OWNER TO renind;

--
-- Name: Usuario_UsuIdUsuario_seq; Type: SEQUENCE; Schema: public; Owner: renind
--

ALTER TABLE public."Usuario" ALTER COLUMN "UsuIdUsuario" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."Usuario_UsuIdUsuario_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: vw_BoletaResumen; Type: VIEW; Schema: public; Owner: renind
--

CREATE VIEW public."vw_BoletaResumen" AS
 SELECT b."BolIdBoleta" AS "IdBoleta",
    b."BolCodEmpleado" AS "CodEmpleado",
    (((u."UsuNombre")::text || ' '::text) || (u."UsuApellidoPaterno")::text) AS "Empleado",
    b."BolPeriodo" AS "Periodo",
    b."BolFechaEmision" AS "FechaEmision",
    d."DetConcepto" AS "Concepto",
    d."DetMonto" AS "Monto",
    b."BolTotal" AS "TotalBoleta"
   FROM (((public."Boleta" b
     JOIN public."DetalleBoleta" d ON ((b."BolIdBoleta" = d."DetIdBoleta")))
     JOIN public."Empleado" e ON (((b."BolCodEmpleado")::text = (e."EmpCodigo")::text)))
     JOIN public."Usuario" u ON ((e."EmpIdUsuario" = u."UsuIdUsuario")))
  ORDER BY b."BolFechaEmision" DESC, b."BolIdBoleta", d."DetIdDetalle";


ALTER TABLE public."vw_BoletaResumen" OWNER TO renind;

--
-- Name: vw_ContratoActivo; Type: VIEW; Schema: public; Owner: renind
--

CREATE VIEW public."vw_ContratoActivo" AS
 SELECT c."ConIdContrato" AS "IdContrato",
    c."ConCodEmpleado" AS "CodEmpleado",
    (((u."UsuNombre")::text || ' '::text) || (u."UsuApellidoPaterno")::text) AS "Empleado",
    m."ModTipo" AS "Modalidad",
    j."JorTipo" AS "Jornada",
    c."ConFechaInicio" AS "FechaInicio",
    c."ConFechaFin" AS "FechaFin",
    c."ConEstado" AS "Estado"
   FROM ((((public."Contrato" c
     JOIN public."Empleado" e ON (((c."ConCodEmpleado")::text = (e."EmpCodigo")::text)))
     JOIN public."Usuario" u ON ((e."EmpIdUsuario" = u."UsuIdUsuario")))
     JOIN public."Modalidad" m ON ((c."ConIdModalidad" = m."ModIdModalidad")))
     JOIN public."Jornada" j ON ((c."ConIdJornada" = j."JorIdJornada")))
  WHERE ((c."ConEstado")::text = 'Activo'::text);


ALTER TABLE public."vw_ContratoActivo" OWNER TO renind;

--
-- Name: vw_EmpleadoCompleto; Type: VIEW; Schema: public; Owner: renind
--

CREATE VIEW public."vw_EmpleadoCompleto" AS
 SELECT e."EmpCodigo" AS "Codigo",
    (((((u."UsuNombre")::text || ' '::text) || (u."UsuApellidoPaterno")::text) || ' '::text) || (u."UsuApellidoMaterno")::text) AS "NombreCompleto",
    u."UsuDni" AS "DNI",
    g."GenNombreGenero" AS "Genero",
    u."UsuEmail" AS "Email",
    u."UsuFechaNacimiento" AS "FechaNacimiento",
    public."fn_CalcularEdad"(e."EmpCodigo") AS "Edad",
    a."AreNombreArea" AS "Area",
    a."AreSalario" AS "Salario",
    e."EmpFechaIngreso" AS "FechaIngreso",
    public."fn_CalcularAntiguedad"(e."EmpCodigo") AS "AntiguedadAnios",
    r."RolNombreRol" AS "Rol",
    u."UsuNombreUsuario" AS "Usuario",
    u."UsuEstado" AS "Estado"
   FROM ((((public."Empleado" e
     JOIN public."Usuario" u ON ((e."EmpIdUsuario" = u."UsuIdUsuario")))
     JOIN public."Area" a ON ((e."EmpIdArea" = a."AreIdArea")))
     JOIN public."Genero" g ON ((u."UsuIdGenero" = g."GenIdGenero")))
     JOIN public."Rol" r ON ((u."UsuIdRol" = r."RolIdRol")))
  WHERE ((u."UsuEstado")::text = 'Activo'::text);


ALTER TABLE public."vw_EmpleadoCompleto" OWNER TO renind;

--
-- Data for Name: Area; Type: TABLE DATA; Schema: public; Owner: renind
--

COPY public."Area" ("AreIdArea", "AreNombreArea", "AreSalario") FROM stdin;
3	Ventas y Marketing	1900.00
4	Desarrollo TI	2200.00
5	Gerencia	2500.00
1	Mantenimiento	1500.00
2	Soporte T├®cnico	2000.00
\.


--
-- Data for Name: AuditoriaLog; Type: TABLE DATA; Schema: public; Owner: renind
--

COPY public."AuditoriaLog" ("AudIdLog", "AudFecha", "AudUsuario", "AudAreIdArea", "AudNombreArea", "AudMontoAnterior", "AudMontoNuevo") FROM stdin;
1	2026-05-24 15:48:31.168002	rrhh_ana	5	Gerencia	2500.00	2501.00
2	2026-05-24 15:48:42.227241	rrhh_ana	5	Gerencia	2501.00	2500.00
3	2026-05-25 15:58:57.572201	admin_carlos	2	Soporte T??cnico	1600.00	2000.00
4	2026-05-25 16:06:46.192541	admin_carlos	1	Mantenimiento	1300.00	1500.00
\.


--
-- Data for Name: Boleta; Type: TABLE DATA; Schema: public; Owner: renind
--

COPY public."Boleta" ("BolIdBoleta", "BolPeriodo", "BolFechaEmision", "BolTotal", "BolCodEmpleado") FROM stdin;
1	Julio 2026	2026-07-25	2800.00	EMP-0001
2	Julio 2026	2026-07-25	2500.00	EMP-0002
3	Julio 2026	2026-07-25	1600.00	EMP-0003
4	Julio 2026	2026-07-25	2200.00	EMP-0004
5	Julio 2026	2026-07-25	1900.00	EMP-0005
6	Junio 2026	2026-06-30	2500.00	EMP-0001
10	Enero 2026	2026-01-31	2500.00	EMP-0001
11	Junio 2025	2025-06-30	2500.00	EMP-0001
13	Julio 2025	2025-07-31	2800.00	EMP-0001
14	Diciembre 2026	2026-12-31	2800.00	EMP-0001
\.


--
-- Data for Name: Contrato; Type: TABLE DATA; Schema: public; Owner: renind
--

COPY public."Contrato" ("ConIdContrato", "ConFechaInicio", "ConFechaFin", "ConIdJornada", "ConIdModalidad", "ConCodEmpleado", "ConEstado") FROM stdin;
1	2020-01-10	2028-12-31	1	1	EMP-0001	Activo
2	2022-03-15	2026-12-31	1	1	EMP-0002	Activo
3	2024-06-01	2025-06-01	1	1	EMP-0003	Activo
4	2023-05-10	\N	1	2	EMP-0004	Activo
5	2021-01-15	\N	1	2	EMP-0005	Activo
6	2025-02-20	2027-02-20	1	1	EMP-0006	Activo
7	2021-11-11	2026-11-11	1	1	EMP-0007	Activo
8	2020-08-05	\N	1	2	EMP-0008	Activo
9	2023-09-21	2024-09-21	1	1	EMP-0009	Finalizado
10	2024-01-10	2025-01-10	1	1	EMP-0010	Activo
\.


--
-- Data for Name: DetalleBoleta; Type: TABLE DATA; Schema: public; Owner: renind
--

COPY public."DetalleBoleta" ("DetIdDetalle", "DetConcepto", "DetMonto", "DetIdBoleta") FROM stdin;
17	Gratificaci├│n Navidad	300.00	14
1	Salario B├ísico Mensual	2500.00	1
3	Salario B├ísico Mensual	2200.00	2
5	Salario B├ísico Mensual	1300.00	3
7	Salario B├ísico Mensual	1900.00	4
9	Salario B├ísico Mensual	1600.00	5
11	Salario B├ísico Mensual	2500.00	6
12	Salario B├ísico Mensual	2500.00	10
13	Salario B├ísico Mensual	2500.00	11
14	Salario B├ísico Mensual	2500.00	13
16	Salario B├ísico Mensual	2500.00	14
2	Gratificaci├│n Fiestas Patrias	300.00	1
4	Gratificaci├│n Fiestas Patrias	300.00	2
6	Gratificaci├│n Fiestas Patrias	300.00	3
8	Gratificaci├│n Fiestas Patrias	300.00	4
10	Gratificaci├│n Fiestas Patrias	300.00	5
15	Gratificaci├│n Fiestas Patrias	300.00	13
\.


--
-- Data for Name: Empleado; Type: TABLE DATA; Schema: public; Owner: renind
--

COPY public."Empleado" ("EmpCodigo", "EmpFechaIngreso", "EmpIdUsuario", "EmpIdArea") FROM stdin;
EMP-0001	2020-01-10	1	5
EMP-0002	2022-03-15	2	4
EMP-0003	2024-06-01	3	1
EMP-0004	2023-05-10	4	3
EMP-0005	2021-01-15	5	2
EMP-0006	2025-02-20	6	5
EMP-0007	2021-11-11	7	4
EMP-0008	2020-08-05	8	3
EMP-0009	2023-09-21	9	2
EMP-0010	2024-01-10	10	1
EMP-0011	2024-05-25	16	5
FDM-0001	2024-05-25	17	2
\.


--
-- Data for Name: Genero; Type: TABLE DATA; Schema: public; Owner: renind
--

COPY public."Genero" ("GenIdGenero", "GenNombreGenero") FROM stdin;
1	Masculino
2	Femenino
\.


--
-- Data for Name: Gratificacion; Type: TABLE DATA; Schema: public; Owner: renind
--

COPY public."Gratificacion" ("GraIdGratificacion", "GraMes", "GraNombre", "GraMonto") FROM stdin;
1	7	Gratificaci??n Fiestas Patrias	300.00
2	12	Gratificaci├│n Navidad	300.00
\.


--
-- Data for Name: Jornada; Type: TABLE DATA; Schema: public; Owner: renind
--

COPY public."Jornada" ("JorIdJornada", "JorTipo") FROM stdin;
1	Tiempo Completo
2	Medio Tiempo
\.


--
-- Data for Name: Modalidad; Type: TABLE DATA; Schema: public; Owner: renind
--

COPY public."Modalidad" ("ModIdModalidad", "ModTipo") FROM stdin;
1	Plazo Determinado
2	Plazo Indeterminado
3	Por Obra o Servicio
\.


--
-- Data for Name: Rol; Type: TABLE DATA; Schema: public; Owner: renind
--

COPY public."Rol" ("RolIdRol", "RolNombreRol") FROM stdin;
1	Administrador
2	Recursos Humanos
3	Empleado Regular
\.


--
-- Data for Name: Usuario; Type: TABLE DATA; Schema: public; Owner: renind
--

COPY public."Usuario" ("UsuIdUsuario", "UsuNombreUsuario", "UsuContrasenia", "UsuDni", "UsuNombre", "UsuApellidoPaterno", "UsuApellidoMaterno", "UsuEmail", "UsuFechaNacimiento", "UsuIdGenero", "UsuIdRol", "UsuEstado") FROM stdin;
1	admin_carlos	Admin123!	70000001	Carlos	Torres	Mendoza	carlos.torres@empresa.pe	1990-05-15	1	1	Activo
2	rrhh_ana	RRHH2026!	70000002	Ana	Vargas	Rios	ana.vargas@empresa.pe	1992-08-22	2	2	Activo
3	emp_luis	Pass2026!	70000003	Luis	Gomez	Perez	luis.gomez@empresa.pe	1998-11-05	1	3	Activo
4	emp_maria	Pass2026!	70000004	Maria	Quispe	Huanca	maria.quispe@empresa.pe	1995-03-18	2	3	Activo
5	emp_jorge	Pass2026!	70000005	Jorge	Mamani	Condori	jorge.mamani@empresa.pe	1993-07-30	1	3	Activo
6	emp_sofia	Pass2026!	70000006	Sofia	Rojas	Silva	sofia.rojas@empresa.pe	1996-12-12	2	3	Activo
7	emp_diego	Pass2026!	70000007	Diego	Castro	Luna	diego.castro@empresa.pe	1991-04-25	1	3	Activo
8	emp_elena	Pass2026!	70000008	Elena	Silva	Campos	elena.silva@empresa.pe	1989-09-08	2	3	Activo
9	emp_pedro	Pass2026!	70000009	Pedro	Morales	Vega	pedro.morales@empresa.pe	1997-01-20	1	3	Activo
10	emp_lucia	Pass2026!	70000010	Lucia	Fernandez	Ruiz	lucia.fernandez@empresa.pe	1999-06-15	2	3	Activo
16	auxx	123456	14785236	andre	pezo	pezo	auxx@gmail.com	2000-01-24	\N	3	Activo
17	federico	1234567	61245886	Federico	Sanchez	Rocha	federico@gmail.com	2001-05-25	\N	3	Activo
\.


--
-- Name: Area_AreIdArea_seq; Type: SEQUENCE SET; Schema: public; Owner: renind
--

SELECT pg_catalog.setval('public."Area_AreIdArea_seq"', 5, true);


--
-- Name: AuditoriaLog_AudIdLog_seq; Type: SEQUENCE SET; Schema: public; Owner: renind
--

SELECT pg_catalog.setval('public."AuditoriaLog_AudIdLog_seq"', 4, true);


--
-- Name: Boleta_BolIdBoleta_seq; Type: SEQUENCE SET; Schema: public; Owner: renind
--

SELECT pg_catalog.setval('public."Boleta_BolIdBoleta_seq"', 14, true);


--
-- Name: Contrato_ConIdContrato_seq; Type: SEQUENCE SET; Schema: public; Owner: renind
--

SELECT pg_catalog.setval('public."Contrato_ConIdContrato_seq"', 10, true);


--
-- Name: DetalleBoleta_DetIdDetalle_seq; Type: SEQUENCE SET; Schema: public; Owner: renind
--

SELECT pg_catalog.setval('public."DetalleBoleta_DetIdDetalle_seq"', 17, true);


--
-- Name: Genero_GenIdGenero_seq; Type: SEQUENCE SET; Schema: public; Owner: renind
--

SELECT pg_catalog.setval('public."Genero_GenIdGenero_seq"', 2, true);


--
-- Name: Gratificacion_GraIdGratificacion_seq; Type: SEQUENCE SET; Schema: public; Owner: renind
--

SELECT pg_catalog.setval('public."Gratificacion_GraIdGratificacion_seq"', 2, true);


--
-- Name: Jornada_JorIdJornada_seq; Type: SEQUENCE SET; Schema: public; Owner: renind
--

SELECT pg_catalog.setval('public."Jornada_JorIdJornada_seq"', 2, true);


--
-- Name: Modalidad_ModIdModalidad_seq; Type: SEQUENCE SET; Schema: public; Owner: renind
--

SELECT pg_catalog.setval('public."Modalidad_ModIdModalidad_seq"', 3, true);


--
-- Name: Rol_RolIdRol_seq; Type: SEQUENCE SET; Schema: public; Owner: renind
--

SELECT pg_catalog.setval('public."Rol_RolIdRol_seq"', 3, true);


--
-- Name: Usuario_UsuIdUsuario_seq; Type: SEQUENCE SET; Schema: public; Owner: renind
--

SELECT pg_catalog.setval('public."Usuario_UsuIdUsuario_seq"', 17, true);


--
-- Name: Area Area_pkey; Type: CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Area"
    ADD CONSTRAINT "Area_pkey" PRIMARY KEY ("AreIdArea");


--
-- Name: AuditoriaLog AuditoriaLog_pkey; Type: CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."AuditoriaLog"
    ADD CONSTRAINT "AuditoriaLog_pkey" PRIMARY KEY ("AudIdLog");


--
-- Name: Boleta Boleta_periodo_empleado_key; Type: CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Boleta"
    ADD CONSTRAINT "Boleta_periodo_empleado_key" UNIQUE ("BolCodEmpleado", "BolPeriodo");


--
-- Name: Boleta Boleta_pkey; Type: CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Boleta"
    ADD CONSTRAINT "Boleta_pkey" PRIMARY KEY ("BolIdBoleta");


--
-- Name: Contrato Contrato_pkey; Type: CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Contrato"
    ADD CONSTRAINT "Contrato_pkey" PRIMARY KEY ("ConIdContrato");


--
-- Name: DetalleBoleta DetalleBoleta_pkey; Type: CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."DetalleBoleta"
    ADD CONSTRAINT "DetalleBoleta_pkey" PRIMARY KEY ("DetIdDetalle");


--
-- Name: Empleado Empleado_EmpIdUsuario_key; Type: CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Empleado"
    ADD CONSTRAINT "Empleado_EmpIdUsuario_key" UNIQUE ("EmpIdUsuario");


--
-- Name: Empleado Empleado_pkey; Type: CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Empleado"
    ADD CONSTRAINT "Empleado_pkey" PRIMARY KEY ("EmpCodigo");


--
-- Name: Genero Genero_pkey; Type: CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Genero"
    ADD CONSTRAINT "Genero_pkey" PRIMARY KEY ("GenIdGenero");


--
-- Name: Gratificacion Gratificacion_mes_key; Type: CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Gratificacion"
    ADD CONSTRAINT "Gratificacion_mes_key" UNIQUE ("GraMes");


--
-- Name: Gratificacion Gratificacion_pkey; Type: CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Gratificacion"
    ADD CONSTRAINT "Gratificacion_pkey" PRIMARY KEY ("GraIdGratificacion");


--
-- Name: Jornada Jornada_JorTipo_key; Type: CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Jornada"
    ADD CONSTRAINT "Jornada_JorTipo_key" UNIQUE ("JorTipo");


--
-- Name: Jornada Jornada_pkey; Type: CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Jornada"
    ADD CONSTRAINT "Jornada_pkey" PRIMARY KEY ("JorIdJornada");


--
-- Name: Modalidad Modalidad_ModTipo_key; Type: CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Modalidad"
    ADD CONSTRAINT "Modalidad_ModTipo_key" UNIQUE ("ModTipo");


--
-- Name: Modalidad Modalidad_pkey; Type: CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Modalidad"
    ADD CONSTRAINT "Modalidad_pkey" PRIMARY KEY ("ModIdModalidad");


--
-- Name: Rol Rol_pkey; Type: CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Rol"
    ADD CONSTRAINT "Rol_pkey" PRIMARY KEY ("RolIdRol");


--
-- Name: Usuario Usuario_UsuDni_key; Type: CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Usuario"
    ADD CONSTRAINT "Usuario_UsuDni_key" UNIQUE ("UsuDni");


--
-- Name: Usuario Usuario_UsuNombreUsuario_key; Type: CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Usuario"
    ADD CONSTRAINT "Usuario_UsuNombreUsuario_key" UNIQUE ("UsuNombreUsuario");


--
-- Name: Usuario Usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Usuario"
    ADD CONSTRAINT "Usuario_pkey" PRIMARY KEY ("UsuIdUsuario");


--
-- Name: Contrato trg_cerrarcontratoanterior; Type: TRIGGER; Schema: public; Owner: renind
--

CREATE TRIGGER trg_cerrarcontratoanterior AFTER INSERT ON public."Contrato" FOR EACH ROW EXECUTE FUNCTION public."fn_CerrarContratoAnterior"();


--
-- Name: AuditoriaLog AuditoriaLog_area_fkey; Type: FK CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."AuditoriaLog"
    ADD CONSTRAINT "AuditoriaLog_area_fkey" FOREIGN KEY ("AudAreIdArea") REFERENCES public."Area"("AreIdArea");


--
-- Name: Boleta Boleta_BolCodEmpleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Boleta"
    ADD CONSTRAINT "Boleta_BolCodEmpleado_fkey" FOREIGN KEY ("BolCodEmpleado") REFERENCES public."Empleado"("EmpCodigo");


--
-- Name: Contrato Contrato_ConCodEmpleado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Contrato"
    ADD CONSTRAINT "Contrato_ConCodEmpleado_fkey" FOREIGN KEY ("ConCodEmpleado") REFERENCES public."Empleado"("EmpCodigo");


--
-- Name: Contrato Contrato_ConIdJornada_fkey; Type: FK CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Contrato"
    ADD CONSTRAINT "Contrato_ConIdJornada_fkey" FOREIGN KEY ("ConIdJornada") REFERENCES public."Jornada"("JorIdJornada");


--
-- Name: Contrato Contrato_ConIdModalidad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Contrato"
    ADD CONSTRAINT "Contrato_ConIdModalidad_fkey" FOREIGN KEY ("ConIdModalidad") REFERENCES public."Modalidad"("ModIdModalidad");


--
-- Name: DetalleBoleta DetalleBoleta_DetIdBoleta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."DetalleBoleta"
    ADD CONSTRAINT "DetalleBoleta_DetIdBoleta_fkey" FOREIGN KEY ("DetIdBoleta") REFERENCES public."Boleta"("BolIdBoleta");


--
-- Name: Empleado Empleado_EmpIdArea_fkey; Type: FK CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Empleado"
    ADD CONSTRAINT "Empleado_EmpIdArea_fkey" FOREIGN KEY ("EmpIdArea") REFERENCES public."Area"("AreIdArea");


--
-- Name: Empleado Empleado_EmpIdUsuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Empleado"
    ADD CONSTRAINT "Empleado_EmpIdUsuario_fkey" FOREIGN KEY ("EmpIdUsuario") REFERENCES public."Usuario"("UsuIdUsuario");


--
-- Name: Usuario Usuario_UsuIdGenero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Usuario"
    ADD CONSTRAINT "Usuario_UsuIdGenero_fkey" FOREIGN KEY ("UsuIdGenero") REFERENCES public."Genero"("GenIdGenero");


--
-- Name: Usuario Usuario_UsuIdRol_fkey; Type: FK CONSTRAINT; Schema: public; Owner: renind
--

ALTER TABLE ONLY public."Usuario"
    ADD CONSTRAINT "Usuario_UsuIdRol_fkey" FOREIGN KEY ("UsuIdRol") REFERENCES public."Rol"("RolIdRol");


--
-- PostgreSQL database dump complete
--

\unrestrict vMXRLVybamCQSaRaaOlDz9kdyc28xPo1FbgP5O0uOh1DBd2itho3MOWNXYspZjR

