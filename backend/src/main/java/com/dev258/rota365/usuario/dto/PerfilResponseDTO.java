package com.dev258.rota365.usuario.dto;

import com.dev258.rota365.usuario.entity.Perfil;

public record PerfilResponseDTO(
        Integer idPerfil,
        String nomePerfil
) {
    public PerfilResponseDTO(Perfil perfil) {
        this(
                perfil.getIdPerfil(),
                perfil.getNomePerfil()
        );
    }
}