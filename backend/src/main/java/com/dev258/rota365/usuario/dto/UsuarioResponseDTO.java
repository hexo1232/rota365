package com.dev258.rota365.usuario.dto;

import com.dev258.rota365.usuario.entity.Usuario;

import java.time.LocalDateTime;

public record UsuarioResponseDTO(
        Integer idUsuario,
        String nome,
        String username,
        Boolean ativo,
        Integer idPerfil,
        String nomePerfil,
        LocalDateTime criadoEm
) {
    public UsuarioResponseDTO(Usuario usuario) {
        this(
                usuario.getIdUsuario(),
                usuario.getNome(),
                usuario.getUsername(),
                usuario.getAtivo(),
                usuario.getPerfil() != null ? usuario.getPerfil().getIdPerfil() : null,
                usuario.getPerfil() != null ? usuario.getPerfil().getNomePerfil() : "Sem perfil",
                usuario.getCriadoEm()
        );
    }
}