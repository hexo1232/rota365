package com.dev258.rota365.usuario.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.NOT_FOUND)
public class UsuarioNotFoundException extends RuntimeException {

    public UsuarioNotFoundException(Long idUsuario) {
        super("Usuário não encontrado com o ID: " + idUsuario);
    }

    public UsuarioNotFoundException(String message) {
        super(message);
    }
}