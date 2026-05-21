package com.accesoriosdm.inventory.service;

import com.accesoriosdm.inventory.dto.CategoriaDTO;
import com.accesoriosdm.inventory.entity.Categoria;
import com.accesoriosdm.inventory.exception.ResourceNotFoundException;
import com.accesoriosdm.inventory.repository.CategoriaRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class CategoriaService {

    private final CategoriaRepository categoriaRepository;

    @Transactional(readOnly = true)
    public List<CategoriaDTO> getAllCategorias() {
        log.info("Obteniendo todas las categorías activas");
        return categoriaRepository.findByEstadoTrue().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public CategoriaDTO getCategoriaById(Integer id) {
        log.info("Buscando categoría con id: {}", id);
        Categoria categoria = categoriaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Categoría no encontrada con id: " + id));
        return convertToDTO(categoria);
    }

    @Transactional(readOnly = true)
    public CategoriaDTO getCategoriaByNombre(String nombre) {
        log.info("Buscando categoría por nombre: {}", nombre);
        Categoria categoria = categoriaRepository.findByNombre(nombre)
                .orElseThrow(() -> new ResourceNotFoundException("Categoría no encontrada con nombre: " + nombre));
        return convertToDTO(categoria);
    }

    @Transactional
    public CategoriaDTO createCategoria(CategoriaDTO categoriaDTO) {
        log.info("Creando nueva categoría: {}", categoriaDTO.getNombre());
        
        Categoria categoria = new Categoria();
        categoria.setNombre(categoriaDTO.getNombre());
        categoria.setDescripcion(categoriaDTO.getDescripcion());
        Boolean estado = categoriaDTO.getEstado();
        categoria.setEstado(estado != null ? estado : Boolean.TRUE);
        
        Categoria saved = categoriaRepository.save(categoria);
        log.info("Categoría creada con id: {}", saved.getIdCategoria());
        
        return convertToDTO(saved);
    }

    @Transactional
    public CategoriaDTO updateCategoria(Integer id, CategoriaDTO categoriaDTO) {
        log.info("Actualizando categoría con id: {}", id);
        
        Categoria categoria = categoriaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Categoría no encontrada con id: " + id));
        
        categoria.setNombre(categoriaDTO.getNombre());
        categoria.setDescripcion(categoriaDTO.getDescripcion());
        if (categoriaDTO.getEstado() != null) {
            categoria.setEstado(categoriaDTO.getEstado());
        }
        
        Categoria updated = categoriaRepository.save(categoria);
        log.info("Categoría actualizada con id: {}", updated.getIdCategoria());
        
        return convertToDTO(updated);
    }

    @Transactional
    public void deleteCategoria(Integer id) {
        log.info("Eliminando categoría con id: {}", id);
        Categoria categoria = categoriaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Categoría no encontrada con id: " + id));
        categoriaRepository.delete(categoria);
        log.info("Categoría eliminada con id: {}", id);
    }

    @Transactional
    public void toggleCategoriaEstado(Integer id) {
        log.info("Cambiando estado de categoría con id: {}", id);
        Categoria categoria = categoriaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Categoría no encontrada con id: " + id));
        categoria.setEstado(!categoria.getEstado());
        categoriaRepository.save(categoria);
        log.info("Nuevo estado de categoría {}: {}", id, categoria.getEstado());
    }

    private CategoriaDTO convertToDTO(Categoria categoria) {
        CategoriaDTO dto = new CategoriaDTO();
        dto.setIdCategoria(categoria.getIdCategoria());
        dto.setNombre(categoria.getNombre());
        dto.setDescripcion(categoria.getDescripcion());
        dto.setEstado(categoria.getEstado());
        return dto;
    }
}