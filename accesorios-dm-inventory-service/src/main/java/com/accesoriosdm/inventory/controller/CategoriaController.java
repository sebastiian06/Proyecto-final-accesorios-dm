package com.accesoriosdm.inventory.controller;

import com.accesoriosdm.inventory.dto.CategoriaDTO;
import com.accesoriosdm.inventory.service.CategoriaService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/categorias")
@RequiredArgsConstructor
@Slf4j
public class CategoriaController {

    private final CategoriaService categoriaService;

    @GetMapping
    public ResponseEntity<List<CategoriaDTO>> getAllCategorias() {
        log.info("GET /categorias - Obteniendo todas las categorías");
        return ResponseEntity.ok(categoriaService.getAllCategorias());
    }

    @GetMapping("/{id}")
    public ResponseEntity<CategoriaDTO> getCategoriaById(@PathVariable Integer id) {
        log.info("GET /categorias/{} - Obteniendo categoría por ID", id);
        return ResponseEntity.ok(categoriaService.getCategoriaById(id));
    }

    @GetMapping("/nombre/{nombre}")
    public ResponseEntity<CategoriaDTO> getCategoriaByNombre(@PathVariable String nombre) {
        log.info("GET /categorias/nombre/{} - Obteniendo categoría por nombre", nombre);
        return ResponseEntity.ok(categoriaService.getCategoriaByNombre(nombre));
    }

    @PostMapping
    public ResponseEntity<CategoriaDTO> createCategoria(@Valid @RequestBody CategoriaDTO categoriaDTO) {
        log.info("POST /categorias - Creando nueva categoría: {}", categoriaDTO.getNombre());
        CategoriaDTO created = categoriaService.createCategoria(categoriaDTO);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<CategoriaDTO> updateCategoria(@PathVariable Integer id, @Valid @RequestBody CategoriaDTO categoriaDTO) {
        log.info("PUT /categorias/{} - Actualizando categoría", id);
        CategoriaDTO updated = categoriaService.updateCategoria(id, categoriaDTO);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCategoria(@PathVariable Integer id) {
        log.info("DELETE /categorias/{} - Eliminando categoría", id);
        categoriaService.deleteCategoria(id);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/toggle-estado")
    public ResponseEntity<Void> toggleCategoriaEstado(@PathVariable Integer id) {
        log.info("PATCH /categorias/{}/toggle-estado - Cambiando estado de categoría", id);
        categoriaService.toggleCategoriaEstado(id);
        return ResponseEntity.ok().build();
    }
}