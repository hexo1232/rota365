package com.dev258.rota365.usuario.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.NOT_FOUND)
public class PerfilNotFoundException extends RuntimeException {

    public PerfilNotFoundException(Long idPerfil) {
        super("Perfil não encontrado com o ID: " + idPerfil);
    }

    public PerfilNotFoundException(String message) {
        super(message);
    }
}