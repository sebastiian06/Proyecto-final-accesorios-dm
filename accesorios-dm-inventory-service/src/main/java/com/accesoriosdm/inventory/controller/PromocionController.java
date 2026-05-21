package com.accesoriosdm.inventory.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.accesoriosdm.inventory.dto.PromocionDTO;
import com.accesoriosdm.inventory.dto.PromocionProductoDTO;
import com.accesoriosdm.inventory.dto.PrecioPromocionalRequest;
import com.accesoriosdm.inventory.service.PromocionService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/promociones")
@RequiredArgsConstructor
@Slf4j
public class PromocionController {

    private final PromocionService promocionService;

    @GetMapping
    public ResponseEntity<List<PromocionDTO>> getAllPromociones() {
        log.info("GET /api/v1/promociones - Obteniendo todas las promociones");
        return ResponseEntity.ok(promocionService.getAllPromociones());
    }

    @GetMapping("/test")
    public String test() {
        return "ok";
    }

    @GetMapping("/{id:\\d+}")
    public ResponseEntity<PromocionDTO> getPromocionById(@PathVariable Integer id) {
        log.info("GET /api/v1/promociones/{} - Obteniendo promoción por ID", id);
        return ResponseEntity.ok(promocionService.getPromocionById(id));
    }

    @PostMapping
    public ResponseEntity<PromocionDTO> createPromocion(@RequestBody PromocionDTO dto) {
        log.info("POST /api/v1/promociones - Creando nueva promoción: {}", dto.getNombre());
        
        PromocionDTO created = promocionService.createPromocion(dto);
        
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id:\\d+}")
    public ResponseEntity<PromocionDTO> updatePromocion(
            @PathVariable Integer id,
            @RequestBody PromocionDTO dto) {
        
        log.info("PUT /api/v1/promociones/{} - Actualizando promoción", id);
        
        PromocionDTO updated = promocionService.updatePromocion(id, dto);
        
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id:\\d+}")
    public ResponseEntity<Void> deletePromocion(@PathVariable Integer id) {
        log.info("DELETE /api/v1/promociones/{} - Eliminando promoción", id);
        
        promocionService.deletePromocion(id);
        
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{idPromocion}/productos/{idProducto}")
    public ResponseEntity<PromocionProductoDTO> asignarPromocionAProducto(
            @PathVariable Integer idPromocion,
            @PathVariable Integer idProducto) {

        log.info(
            "POST /api/v1/promociones/{}/productos/{} - Asignando promoción a producto",
            idPromocion,
            idProducto
        );

        PromocionProductoDTO result =
                promocionService.asignarPromocionAProducto(idPromocion, idProducto);

        return ResponseEntity.status(HttpStatus.CREATED).body(result);
    }

    @DeleteMapping("/{idPromocion}/productos/{idProducto}")
    public ResponseEntity<Void> desasociarPromocionDeProducto(
            @PathVariable Integer idPromocion,
            @PathVariable Integer idProducto) {

        log.info(
    "DELETE /api/v1/promociones/{}/productos/{} - Desasociando promoción de producto",
            idPromocion,
            idProducto
        );

        promocionService.desasociarPromocionDeProducto(idPromocion, idProducto);

        return ResponseEntity.noContent().build();
    }

}