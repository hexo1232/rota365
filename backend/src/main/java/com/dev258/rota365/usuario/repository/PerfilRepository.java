package com.dev258.rota365.usuario.repository;

import com.dev258.rota365.usuario.entity.Perfil;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PerfilRepository extends JpaRepository<Perfil, Integer> {

    Optional<Perfil> findByNomePerfilIgnoreCase(String nomePerfil);

    boolean existsByNomePerfilIgnoreCase(String nomePerfil);

    @Query("""
           SELECT p
           FROM Perfil p
           WHERE LOWER(p.nomePerfil) <> 'administrador'
           ORDER BY p.nomePerfil ASC
           """)
    List<Perfil> findPerfisOperacionais();
}