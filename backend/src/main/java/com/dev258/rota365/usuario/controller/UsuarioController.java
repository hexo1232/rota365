package com.dev258.rota365.usuario.controller;

import com.dev258.rota365.usuario.dto.AlterarSenhaRequestDTO;
import com.dev258.rota365.usuario.dto.LoginRequestDTO;
import com.dev258.rota365.usuario.dto.LoginResponseDTO;
import com.dev258.rota365.usuario.dto.UsuarioRequestDTO;
import com.dev258.rota365.usuario.dto.UsuarioResponseDTO;
import com.dev258.rota365.usuario.service.UsuarioService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class UsuarioController {

    private final UsuarioService usuarioService;

    // ─────────────────────────────────────────────────────────────
    // USUÁRIOS
    // Base: /api/usuarios
    // ─────────────────────────────────────────────────────────────

    @GetMapping("/api/usuarios")
    public ResponseEntity<List<UsuarioResponseDTO>> listar(
            @RequestParam(required = false) Boolean ativo
    ) {
        return ResponseEntity.ok(usuarioService.listar(ativo));
    }

    @GetMapping("/api/usuarios/{idUsuario}")
    public ResponseEntity<UsuarioResponseDTO> buscarPorId(
            @PathVariable Long idUsuario
    ) {
        return ResponseEntity.ok(usuarioService.buscarPorId(idUsuario));
    }

    @PostMapping("/api/usuarios")
    public ResponseEntity<UsuarioResponseDTO> criar(
            @Valid @RequestBody UsuarioRequestDTO dto
    ) {
        UsuarioResponseDTO response = usuarioService.criar(dto);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(response);
    }

    @PutMapping("/api/usuarios/{idUsuario}")
    public ResponseEntity<UsuarioResponseDTO> atualizar(
            @PathVariable Long idUsuario,
            @Valid @RequestBody UsuarioRequestDTO dto
    ) {
        return ResponseEntity.ok(usuarioService.atualizar(idUsuario, dto));
    }

    @PatchMapping("/api/usuarios/{idUsuario}/toggle-ativo")
    public ResponseEntity<UsuarioResponseDTO> toggleAtivo(
            @PathVariable Long idUsuario
    ) {
        return ResponseEntity.ok(usuarioService.toggleAtivo(idUsuario));
    }

    @PatchMapping("/api/usuarios/{idUsuario}/ativar")
    public ResponseEntity<UsuarioResponseDTO> ativar(
            @PathVariable Long idUsuario
    ) {
        return ResponseEntity.ok(usuarioService.ativar(idUsuario));
    }

    @PatchMapping("/api/usuarios/{idUsuario}/desativar")
    public ResponseEntity<UsuarioResponseDTO> desativar(
            @PathVariable Long idUsuario
    ) {
        return ResponseEntity.ok(usuarioService.desativar(idUsuario));
    }

    @PostMapping("/api/usuarios/{idUsuario}/reset-senha")
    public ResponseEntity<Map<String, String>> resetarSenha(
            @PathVariable Long idUsuario
    ) {
        usuarioService.resetarSenha(idUsuario);

        return ResponseEntity.ok(
                Map.of("mensagem", "Senha redefinida com sucesso.")
        );
    }

    @PatchMapping("/api/usuarios/{idUsuario}/alterar-senha")
    public ResponseEntity<Map<String, String>> alterarSenha(
            @PathVariable Long idUsuario,
            @Valid @RequestBody AlterarSenhaRequestDTO dto
    ) {
        usuarioService.alterarSenha(idUsuario, dto);

        return ResponseEntity.ok(
                Map.of("mensagem", "Senha alterada com sucesso.")
        );
    }

    // ─────────────────────────────────────────────────────────────
    // AUTENTICAÇÃO
    // Base: /api/auth
    // ─────────────────────────────────────────────────────────────

    @PostMapping("/api/auth/login")
    public ResponseEntity<LoginResponseDTO> login(
            @Valid @RequestBody LoginRequestDTO dto
    ) {
        return ResponseEntity.ok(usuarioService.login(dto));
    }
}