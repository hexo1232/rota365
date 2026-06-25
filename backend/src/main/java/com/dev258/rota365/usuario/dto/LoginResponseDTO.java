package com.dev258.rota365.usuario.dto;

public record LoginResponseDTO(
        UsuarioResponseDTO usuario,
        String token
) {}