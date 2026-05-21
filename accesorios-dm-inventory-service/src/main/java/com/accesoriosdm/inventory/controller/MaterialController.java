package com.accesoriosdm.inventory.controller;

import com.accesoriosdm.inventory.dto.MaterialDTO;
import com.accesoriosdm.inventory.service.MaterialService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/materiales")
@RequiredArgsConstructor
@Slf4j
public class MaterialController {

    private final MaterialService materialService;

    @GetMapping
    public ResponseEntity<List<MaterialDTO>> getAllMateriales() {
        log.info("GET /materiales - Obteniendo todos los materiales");
        return ResponseEntity.ok(materialService.getAllMateriales());
    }

    @GetMapping("/{id}")
    public ResponseEntity<MaterialDTO> getMaterialById(@PathVariable Integer id) {
        log.info("GET /materiales/{} - Obteniendo material por ID", id);
        return ResponseEntity.ok(materialService.getMaterialById(id));
    }

    @GetMapping("/nombre/{nombre}")
    public ResponseEntity<MaterialDTO> getMaterialByNombre(@PathVariable String nombre) {
        log.info("GET /materiales/nombre/{} - Obteniendo material por nombre", nombre);
        return ResponseEntity.ok(materialService.getMaterialByNombre(nombre));
    }

    @PostMapping
    public ResponseEntity<MaterialDTO> createMaterial(@Valid @RequestBody MaterialDTO materialDTO) {
        log.info("POST /materiales - Creando nuevo material: {}", materialDTO.getNombre());
        MaterialDTO created = materialService.createMaterial(materialDTO);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<MaterialDTO> updateMaterial(@PathVariable Integer id, @Valid @RequestBody MaterialDTO materialDTO) {
        log.info("PUT /materiales/{} - Actualizando material", id);
        MaterialDTO updated = materialService.updateMaterial(id, materialDTO);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMaterial(@PathVariable Integer id) {
        log.info("DELETE /materiales/{} - Eliminando material", id);
        materialService.deleteMaterial(id);
        return ResponseEntity.noContent().build();
    }
}