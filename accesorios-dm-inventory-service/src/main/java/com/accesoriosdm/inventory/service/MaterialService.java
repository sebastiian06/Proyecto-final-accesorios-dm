package com.accesoriosdm.inventory.service;

import com.accesoriosdm.inventory.dto.MaterialDTO;
import com.accesoriosdm.inventory.entity.Material;
import com.accesoriosdm.inventory.exception.ResourceNotFoundException;
import com.accesoriosdm.inventory.repository.MaterialRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class MaterialService {

    private final MaterialRepository materialRepository;

    @Transactional(readOnly = true)
    public List<MaterialDTO> getAllMateriales() {
        log.info("Obteniendo todos los materiales");
        return materialRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public MaterialDTO getMaterialById(Integer id) {
        log.info("Buscando material con id: {}", id);
        Material material = materialRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Material no encontrado con id: " + id));
        return convertToDTO(material);
    }

    @Transactional(readOnly = true)
    public MaterialDTO getMaterialByNombre(String nombre) {
        log.info("Buscando material por nombre: {}", nombre);
        Material material = materialRepository.findByNombre(nombre)
                .orElseThrow(() -> new ResourceNotFoundException("Material no encontrado con nombre: " + nombre));
        return convertToDTO(material);
    }

    @Transactional
    public MaterialDTO createMaterial(MaterialDTO materialDTO) {
        log.info("Creando nuevo material: {}", materialDTO.getNombre());
        
        Material material = new Material();
        material.setNombre(materialDTO.getNombre());
        material.setDescripcion(materialDTO.getDescripcion());
        
        Material saved = materialRepository.save(material);
        log.info("Material creado con id: {}", saved.getIdMaterial());
        
        return convertToDTO(saved);
    }

    @Transactional
    public MaterialDTO updateMaterial(Integer id, MaterialDTO materialDTO) {
        log.info("Actualizando material con id: {}", id);
        
        Material material = materialRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Material no encontrado con id: " + id));
        
        material.setNombre(materialDTO.getNombre());
        material.setDescripcion(materialDTO.getDescripcion());
        
        Material updated = materialRepository.save(material);
        log.info("Material actualizado con id: {}", updated.getIdMaterial());
        
        return convertToDTO(updated);
    }

    @Transactional
    public void deleteMaterial(Integer id) {
        log.info("Eliminando material con id: {}", id);
        Material material = materialRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Material no encontrado con id: " + id));
        materialRepository.delete(material);
        log.info("Material eliminado con id: {}", id);
    }

    private MaterialDTO convertToDTO(Material material) {
        MaterialDTO dto = new MaterialDTO();
        dto.setIdMaterial(material.getIdMaterial());
        dto.setNombre(material.getNombre());
        dto.setDescripcion(material.getDescripcion());
        return dto;
    }
}