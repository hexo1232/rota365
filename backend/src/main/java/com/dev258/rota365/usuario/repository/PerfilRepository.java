package com.dev258.rota365.usuario.repository;

import com.dev258.rota365.usuario.entity.Perfil;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PerfilRepository extends JpaRepository<Perfil, Integer> {

    Optional<Perfil> findByNomePerfilIgnoreCase(String nomePerfil);

    boolean existsByNomePerfilIgnoreCase(String nomePerfil);
}