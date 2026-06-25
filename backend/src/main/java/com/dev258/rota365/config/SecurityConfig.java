package com.dev258.rota365.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    /*
     * Configuração inicial para o Rota365.
     *
     * Nesta fase:
     * - liberamos o login;
     * - liberamos temporariamente as rotas de usuário para facilitar testes;
     * - desativamos CSRF porque a API será consumida pelo Flutter;
     * - mantemos estrutura pronta para evoluir para JWT depois.
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        return http
                .csrf(AbstractHttpConfigurer::disable)
                .cors(Customizer.withDefaults())

                .authorizeHttpRequests(auth -> auth

                        // ── Autenticação ─────────────────────────────
                        .requestMatchers(HttpMethod.POST, "/api/auth/login").permitAll()

                        // ── Usuários temporariamente livres para testes ─
                        .requestMatchers("/api/usuarios/**").permitAll()

                        // ── Health check, se adicionaste Actuator ─────
                        .requestMatchers("/actuator/health").permitAll()

                        // ── Qualquer outra rota exige autenticação ─────
                        .anyRequest().authenticated()
                )

                /*
                 * HTTP Basic fica activo apenas para facilitar testes manuais.
                 * Quando entrarmos com JWT, poderemos remover isto.
                 */
                .httpBasic(Customizer.withDefaults())

                .build();
    }

    /*
     * Expõe o AuthenticationManager como bean.
     * Será útil quando evoluirmos para autenticação real com JWT.
     */
    @Bean
    public AuthenticationManager authenticationManager(
            AuthenticationConfiguration configuration
    ) throws Exception {
        return configuration.getAuthenticationManager();
    }
}