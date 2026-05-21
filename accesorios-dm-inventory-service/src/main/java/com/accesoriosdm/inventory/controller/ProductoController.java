package com.accesoriosdm.inventory.controller;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.accesoriosdm.inventory.dto.ImagenProductoDTO;
import com.accesoriosdm.inventory.dto.ProductoDTO;
import com.accesoriosdm.inventory.dto.ProductoResumenDTO;
import com.accesoriosdm.inventory.service.ProductoService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/productos")
@RequiredArgsConstructor
@Slf4j
public class ProductoController {

    private final ProductoService productoService;

    // ========== ENDPOINTS PÚBLICOS PARA FRONTEND ==========

    @GetMapping
    public ResponseEntity<List<ProductoResumenDTO>> getAllProductos() {
        log.info("GET /productos - Obteniendo todos los productos activos");
        return ResponseEntity.ok(productoService.getAllProductos());
    }

    @GetMapping("/paginated")
    public ResponseEntity<Page<ProductoResumenDTO>> getAllProductosPaginado(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size,
            @RequestParam(defaultValue = "idProducto") String sortBy,
            @RequestParam(defaultValue = "asc") String direction) {
        
        Sort.Direction sortDirection = direction.equalsIgnoreCase("desc") ? Sort.Direction.DESC : Sort.Direction.ASC;
        Pageable pageable = PageRequest.of(page, size, Sort.by(sortDirection, sortBy));
        
        log.info("GET /productos/paginated - page={}, size={}", page, size);
        return ResponseEntity.ok(productoService.getAllProductosPaginado(pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductoDTO> getProductoById(@PathVariable Integer id) {
        log.info("GET /productos/{} - Obteniendo producto por ID", id);
        return ResponseEntity.ok(productoService.getProductoById(id));
    }

    @GetMapping("/categoria/{categoriaId}")
    public ResponseEntity<List<ProductoResumenDTO>> getProductosByCategoria(@PathVariable Integer categoriaId) {
        log.info("GET /productos/categoria/{} - Obteniendo productos por categoría", categoriaId);
        return ResponseEntity.ok(productoService.getProductosByCategoria(categoriaId));
    }

    @GetMapping("/categoria/{categoriaId}/paginated")
    public ResponseEntity<Page<ProductoResumenDTO>> getProductosByCategoriaPaginado(
            @PathVariable Integer categoriaId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size) {
        
        Pageable pageable = PageRequest.of(page, size);
        log.info("GET /productos/categoria/{}/paginated - page={}, size={}", categoriaId, page, size);
        return ResponseEntity.ok(productoService.getProductosByCategoriaPaginado(categoriaId, pageable));
    }

    @GetMapping("/disponibles")
    public ResponseEntity<List<ProductoResumenDTO>> getProductosDisponibles() {
        log.info("GET /productos/disponibles - Obteniendo productos con stock");
        return ResponseEntity.ok(productoService.getProductosDisponibles());
    }

    @GetMapping("/disponibles/categoria/{categoriaId}")
    public ResponseEntity<List<ProductoResumenDTO>> getProductosDisponiblesByCategoria(@PathVariable Integer categoriaId) {
        log.info("GET /productos/disponibles/categoria/{} - Obteniendo productos disponibles por categoría", categoriaId);
        return ResponseEntity.ok(productoService.getProductosDisponiblesByCategoria(categoriaId));
    }

    @GetMapping("/search")
    public ResponseEntity<List<ProductoResumenDTO>> searchProductos(@RequestParam String nombre) {
        log.info("GET /productos/search?nombre={} - Buscando productos", nombre);
        return ResponseEntity.ok(productoService.searchProductosByNombre(nombre));
    }

    @GetMapping("/{productoId}/imagenes")
    public ResponseEntity<List<ImagenProductoDTO>> getImagenesByProducto(@PathVariable Integer productoId) {
        log.info("GET /productos/{}/imagenes - Obteniendo imágenes del producto", productoId);
        return ResponseEntity.ok(productoService.getImagenesByProducto(productoId));
    }

    // ========== ENDPOINTS DE ADMINISTRACIÓN ==========

    @PostMapping
    public ResponseEntity<ProductoDTO> createProducto(@Valid @RequestBody ProductoDTO productoDTO) {
        log.info("POST /productos - Creando nuevo producto: {}", productoDTO.getNombre());
        ProductoDTO created = productoService.createProducto(productoDTO);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ProductoDTO> updateProducto(@PathVariable Integer id, @Valid @RequestBody ProductoDTO productoDTO) {
        log.info("PUT /productos/{} - Actualizando producto", id);
        ProductoDTO updated = productoService.updateProducto(id, productoDTO);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProducto(@PathVariable Integer id) {
        log.info("DELETE /productos/{} - Eliminando producto", id);
        productoService.deleteProducto(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{productoId}/imagenes")
    public ResponseEntity<ImagenProductoDTO> addImagenToProducto(
            @PathVariable Integer productoId,
            @RequestParam("file") MultipartFile file,
            @RequestParam(required = false, defaultValue = "1") Integer orden) {

        log.info("POST /productos/{}/imagenes - Subiendo imagen", productoId);

        ImagenProductoDTO imagen =
                productoService.addImagenToProducto(productoId, file, orden);

        return ResponseEntity.status(HttpStatus.CREATED).body(imagen);
    }

    @PostMapping("/{productoId}/imagenes/upload")
    public ResponseEntity<ImagenProductoDTO> uploadImagenProducto(
            @PathVariable Integer productoId,
            @RequestParam("file") MultipartFile file,
            @RequestParam(required = false, defaultValue = "1") Integer orden) {

        log.info("POST /productos/{}/imagenes/upload - Subiendo imagen", productoId);

        ImagenProductoDTO imagen =
                productoService.uploadImagenProducto(
                        productoId,
                        file,
                        orden
             );

        return ResponseEntity.status(HttpStatus.CREATED).body(imagen);
    }

    @DeleteMapping("/imagenes/{imagenId}")
    public ResponseEntity<Void> deleteImagenFromProducto(@PathVariable Integer imagenId) {
        log.info("DELETE /productos/imagenes/{} - Eliminando imagen", imagenId);
        productoService.deleteImagenFromProducto(imagenId);
        return ResponseEntity.noContent().build();
    }
}