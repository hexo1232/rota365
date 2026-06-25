package com.dev258.rota365.usuario.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.CONFLICT)
public class UsernameJaExisteException extends RuntimeException {

    public UsernameJaExisteException(String username) {
        super("Já existe um usuário cadastrado com o username: " + username);
    }
}