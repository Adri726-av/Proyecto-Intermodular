CREATE DATABASE mazos_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE mazos_db;
 
CREATE TABLE formato (
    id_formato  INT AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(50) NOT NULL,
    descripcion TEXT,
    CONSTRAINT chk_formato_nombre CHECK (CHAR_LENGTH(TRIM(nombre)) > 0)
);
 
CREATE TABLE pregunta (
    id_pregunta INT AUTO_INCREMENT PRIMARY KEY,
    texto       VARCHAR(255) NOT NULL,
    obligatoria BOOLEAN NOT NULL DEFAULT TRUE,
    activa      BOOLEAN NOT NULL DEFAULT TRUE,
    id_formato  INT NOT NULL,
    FOREIGN KEY (id_formato) REFERENCES formato(id_formato),
    CONSTRAINT chk_pregunta_texto CHECK (CHAR_LENGTH(TRIM(texto)) > 0)
);
 
CREATE TABLE respuesta (
    id_respuesta INT AUTO_INCREMENT PRIMARY KEY,
    id_pregunta  INT NOT NULL,
    texto        VARCHAR(255) NOT NULL,
    FOREIGN KEY (id_pregunta) REFERENCES pregunta(id_pregunta),
    CONSTRAINT chk_respuesta_texto CHECK (CHAR_LENGTH(TRIM(texto)) > 0)
);
 
CREATE TABLE mazo (
    id_mazo     INT AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    id_formato  INT NOT NULL,
    colores     VARCHAR(50),
    estilo      VARCHAR(50),
    descripcion TEXT,
    enlace      VARCHAR(255),
    activo      BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (id_formato) REFERENCES formato(id_formato),
    CONSTRAINT chk_mazo_nombre CHECK (CHAR_LENGTH(TRIM(nombre)) > 0),
    CONSTRAINT chk_mazo_enlace CHECK (enlace IS NULL OR enlace LIKE 'http%')
);
 

CREATE TABLE puntuacion (
    id_respuesta INT NOT NULL,
    id_mazo      INT NOT NULL,
    puntos       INT NOT NULL,
    PRIMARY KEY (id_respuesta, id_mazo),
    FOREIGN KEY (id_respuesta) REFERENCES respuesta(id_respuesta),
    FOREIGN KEY (id_mazo) REFERENCES mazo(id_mazo),
    CONSTRAINT chk_puntuacion_puntos CHECK (puntos >= 0)
);