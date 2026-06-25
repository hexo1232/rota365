package com.dev258.rota365.usuario.repository;

import com.dev258.rota365.usuario.entity.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    Optional<Usuario> findByUsernameIgnoreCase(String username);

    boolean existsByUsernameIgnoreCase(String username);

    List<Usuario> findByAtivo(Boolean ativo);

    @Query("""
           SELECT u
           FROM Usuario u
           LEFT JOIN FETCH u.perfil
           WHERE u.idUsuario = :idUsuario
           """)
    Optional<Usuario> findByIdComPerfil(@Param("idUsuario") Long idUsuario);

    @Query("""
           SELECT u
           FROM Usuario u
           LEFT JOIN FETCH u.perfil
           WHERE LOWER(u.username) = LOWER(:username)
           """)
    Optional<Usuario> findByUsernameComPerfil(@Param("username") String username);

    @Query("""
           SELECT u
           FROM Usuario u
           LEFT JOIN FETCH u.perfil
           ORDER BY u.idUsuario DESC
           """)
    List<Usuario> findAllComPerfil();

    @Query("""
           SELECT u
           FROM Usuario u
           LEFT JOIN FETCH u.perfil
           WHERE u.ativo = :ativo
           ORDER BY u.idUsuario DESC
           """)
    List<Usuario> findByAtivoComPerfil(@Param("ativo") Boolean ativo);
}