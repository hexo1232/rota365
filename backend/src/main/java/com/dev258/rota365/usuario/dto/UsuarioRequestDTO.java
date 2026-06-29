package com.dev258.rota365.usuario.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UsuarioRequestDTO(

        @NotBlank(message = "O nome é obrigatório")
        @Size(max = 100, message = "O nome deve ter no máximo 100 caracteres")
        String nome,

        @NotBlank(message = "O username é obrigatório")
        @Size(max = 50, message = "O username deve ter no máximo 50 caracteres")
        String username,

        /*
         * Opcional:
         * - Se vier preenchida, o backend usa esta senha.
         * - Se vier vazia/null, o service poderá usar uma senha padrão.
         */
        @Size(min = 6, max = 100, message = "A senha deve ter entre 6 e 100 caracteres")
        String senha,

        /*
         * No schema, id_perfil pode ser NULL.
         * Por isso, deixamos opcional no DTO.
         * Se quiseres obrigar perfil na regra de negócio, validamos no service.
         */
        Integer idPerfil
) {}