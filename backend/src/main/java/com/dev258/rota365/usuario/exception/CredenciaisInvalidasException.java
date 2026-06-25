package com.dev258.rota365.usuario.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.UNAUTHORIZED)
public class CredenciaisInvalidasException extends RuntimeException {

    public CredenciaisInvalidasException() {
        super("Username ou senha inválidos.");
    }

    public CredenciaisInvalidasException(String message) {
        super(message);
    }
}