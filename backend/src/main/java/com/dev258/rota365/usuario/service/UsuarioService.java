package com.dev258.rota365.usuario.service;

import com.dev258.rota365.usuario.dto.AlterarSenhaRequestDTO;
import com.dev258.rota365.usuario.dto.LoginRequestDTO;
import com.dev258.rota365.usuario.dto.LoginResponseDTO;
import com.dev258.rota365.usuario.dto.UsuarioRequestDTO;
import com.dev258.rota365.usuario.dto.UsuarioResponseDTO;
import com.dev258.rota365.usuario.entity.Perfil;
import com.dev258.rota365.usuario.entity.Usuario;
import com.dev258.rota365.usuario.exception.CredenciaisInvalidasException;
import com.dev258.rota365.usuario.exception.PerfilNotFoundException;
import com.dev258.rota365.usuario.exception.UsernameJaExisteException;
import com.dev258.rota365.usuario.exception.UsuarioNotFoundException;
import com.dev258.rota365.usuario.repository.PerfilRepository;
import com.dev258.rota365.usuario.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UsuarioService {

    private static final String SENHA_PADRAO = "123456";

    private final UsuarioRepository usuarioRepository;
    private final PerfilRepository perfilRepository;
    private final PasswordEncoder passwordEncoder;

    // ─────────────────────────────────────────────────────────────
    // LISTAGEM
    // ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<UsuarioResponseDTO> listar(Boolean ativo) {
        if (ativo == null) {
            return usuarioRepository.findAllComPerfil()
                    .stream()
                    .map(UsuarioResponseDTO::new)
                    .toList();
        }

        return usuarioRepository.findByAtivoComPerfil(ativo)
                .stream()
                .map(UsuarioResponseDTO::new)
                .toList();
    }

    // ─────────────────────────────────────────────────────────────
    // BUSCA POR ID
    // ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public UsuarioResponseDTO buscarPorId(Long idUsuario) {
        Usuario usuario = buscarUsuarioOuLancar(idUsuario);
        return new UsuarioResponseDTO(usuario);
    }

    // ─────────────────────────────────────────────────────────────
    // CRIAÇÃO
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public UsuarioResponseDTO criar(UsuarioRequestDTO dto) {
        validarUsernameDisponivel(dto.username());

        Perfil perfil = buscarPerfilSeInformado(dto.idPerfil());

        String senhaBruta = resolverSenha(dto.senha());

        Usuario usuario = Usuario.builder()
                .nome(dto.nome().trim())
                .username(dto.username().trim())
                .senhaHash(passwordEncoder.encode(senhaBruta))
                .ativo(true)
                .perfil(perfil)
                .build();

        Usuario salvo = usuarioRepository.save(usuario);

        return new UsuarioResponseDTO(salvo);
    }

    // ─────────────────────────────────────────────────────────────
    // EDIÇÃO
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public UsuarioResponseDTO atualizar(Long idUsuario, UsuarioRequestDTO dto) {
        Usuario usuario = buscarUsuarioOuLancar(idUsuario);

        String novoUsername = dto.username().trim();

        if (!usuario.getUsername().equalsIgnoreCase(novoUsername)
                && usuarioRepository.existsByUsernameIgnoreCase(novoUsername)) {
            throw new UsernameJaExisteException(novoUsername);
        }

        Perfil perfil = buscarPerfilSeInformado(dto.idPerfil());

        usuario.setNome(dto.nome().trim());
        usuario.setUsername(novoUsername);
        usuario.setPerfil(perfil);

        if (dto.senha() != null && !dto.senha().isBlank()) {
            usuario.setSenhaHash(passwordEncoder.encode(dto.senha()));
        }

        Usuario atualizado = usuarioRepository.save(usuario);

        return new UsuarioResponseDTO(atualizado);
    }

    // ─────────────────────────────────────────────────────────────
    // ACTIVAR / DESACTIVAR
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public UsuarioResponseDTO toggleAtivo(Long idUsuario) {
        Usuario usuario = buscarUsuarioOuLancar(idUsuario);

        usuario.setAtivo(!Boolean.TRUE.equals(usuario.getAtivo()));

        Usuario atualizado = usuarioRepository.save(usuario);

        return new UsuarioResponseDTO(atualizado);
    }

    @Transactional
    public UsuarioResponseDTO ativar(Long idUsuario) {
        Usuario usuario = buscarUsuarioOuLancar(idUsuario);

        usuario.setAtivo(true);

        Usuario atualizado = usuarioRepository.save(usuario);

        return new UsuarioResponseDTO(atualizado);
    }

    @Transactional
    public UsuarioResponseDTO desativar(Long idUsuario) {
        Usuario usuario = buscarUsuarioOuLancar(idUsuario);

        usuario.setAtivo(false);

        Usuario atualizado = usuarioRepository.save(usuario);

        return new UsuarioResponseDTO(atualizado);
    }

    // ─────────────────────────────────────────────────────────────
    // RESET DE SENHA
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public void resetarSenha(Long idUsuario) {
        Usuario usuario = buscarUsuarioOuLancar(idUsuario);

        usuario.setSenhaHash(passwordEncoder.encode(SENHA_PADRAO));

        usuarioRepository.save(usuario);
    }

    // ─────────────────────────────────────────────────────────────
    // ALTERAR SENHA
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public void alterarSenha(Long idUsuario, AlterarSenhaRequestDTO dto) {
        Usuario usuario = buscarUsuarioOuLancar(idUsuario);

        if (!passwordEncoder.matches(dto.senhaAtual(), usuario.getSenhaHash())) {
            throw new CredenciaisInvalidasException("A senha actual está incorrecta.");
        }

        usuario.setSenhaHash(passwordEncoder.encode(dto.novaSenha()));

        usuarioRepository.save(usuario);
    }

    // ─────────────────────────────────────────────────────────────
    // LOGIN
    // ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public LoginResponseDTO login(LoginRequestDTO dto) {
        Usuario usuario = usuarioRepository.findByUsernameComPerfil(dto.username())
                .orElseThrow(CredenciaisInvalidasException::new);

        if (!Boolean.TRUE.equals(usuario.getAtivo())) {
            throw new CredenciaisInvalidasException("Conta inactiva. Contacte o administrador.");
        }

        if (!passwordEncoder.matches(dto.senha(), usuario.getSenhaHash())) {
            throw new CredenciaisInvalidasException();
        }

        /*
         * Nesta fase ainda não criámos JWT.
         * Por isso, o token fica null temporariamente.
         * Quando criarmos a camada config/security, substituímos isto por:
         *
         * String token = jwtService.gerarToken(usuario);
         *
         * e retornamos o token real.
         */
        return new LoginResponseDTO(
                new UsuarioResponseDTO(usuario),
                null
        );
    }

    // ─────────────────────────────────────────────────────────────
    // HELPERS PRIVADOS
    // ─────────────────────────────────────────────────────────────

    private Usuario buscarUsuarioOuLancar(Long idUsuario) {
        return usuarioRepository.findByIdComPerfil(idUsuario)
                .orElseThrow(() -> new UsuarioNotFoundException(idUsuario));
    }

    private void validarUsernameDisponivel(String username) {
        if (usuarioRepository.existsByUsernameIgnoreCase(username.trim())) {
            throw new UsernameJaExisteException(username);
        }
    }

    private Perfil buscarPerfilSeInformado(Long idPerfil) {
        if (idPerfil == null) {
            return null;
        }

        return perfilRepository.findById(idPerfil)
                .orElseThrow(() -> new PerfilNotFoundException(idPerfil));
    }

    private String resolverSenha(String senha) {
        if (senha == null || senha.isBlank()) {
            return SENHA_PADRAO;
        }

        return senha;
    }
}