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

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        return http
                .csrf(AbstractHttpConfigurer::disable)
                .cors(Customizer.withDefaults())

                .authorizeHttpRequests(auth -> auth
                        // ─────────────────────────────────────────────
                        // AUTENTICAÇÃO
                        // ─────────────────────────────────────────────
                        .requestMatchers(HttpMethod.POST, "/api/auth/login").permitAll()

                        // ─────────────────────────────────────────────
                        // USUÁRIOS
                        // Temporariamente liberado em fase de testes.
                        // Depois, quando implementarmos JWT, protegemos.
                        // ─────────────────────────────────────────────
                        .requestMatchers("/api/usuarios/**").permitAll()

                        // ─────────────────────────────────────────────
                        // PERFIS
                        // Necessário para o formulário de cadastro carregar
                        // Gerente, Vendedor, Cliente, etc.
                        // ─────────────────────────────────────────────
                        .requestMatchers(HttpMethod.GET, "/api/perfis").permitAll()

                        // ─────────────────────────────────────────────
                        // HEALTH CHECK
                        // ─────────────────────────────────────────────
                        .requestMatchers("/actuator/health").permitAll()

                        // ─────────────────────────────────────────────
                        // RESTANTE
                        // ─────────────────────────────────────────────
                        .anyRequest().authenticated()
                )

                .httpBasic(Customizer.withDefaults())

                .build();
    }

    @Bean
    public AuthenticationManager authenticationManager(
            AuthenticationConfiguration configuration
    ) throws Exception {
        return configuration.getAuthenticationManager();
    }
}