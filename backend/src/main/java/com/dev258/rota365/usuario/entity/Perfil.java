package com.dev258.rota365.usuario.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "perfil")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Perfil {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_perfil")
   private Integer idPerfil;

    @Column(name = "nome_perfil", nullable = false, length = 50)
    private String nomePerfil;
}