package com.accesoriosdm.inventory.service;

import com.accesoriosdm.inventory.dto.PromocionDTO;
import com.accesoriosdm.inventory.dto.PromocionProductoDTO;
import com.accesoriosdm.inventory.entity.Producto;
import com.accesoriosdm.inventory.entity.Promocion;
import com.accesoriosdm.inventory.entity.PromocionProducto;
import com.accesoriosdm.inventory.repository.PromocionRepository;
import com.accesoriosdm.inventory.repository.ProductoRepository;
import com.accesoriosdm.inventory.repository.PromocionProductoRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class PromocionService {

    private final PromocionRepository promocionRepository;
    private final PromocionProductoRepository promocionProductoRepository;
    private final ProductoRepository productoRepository;

    @Transactional(readOnly = true)
    public List<PromocionDTO> getAllPromociones() {
        return promocionRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public PromocionDTO getPromocionById(Integer id) {
        Promocion promocion = promocionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Promoción no encontrada"));
        return convertToDTO(promocion);
    }

    @Transactional
    public PromocionDTO createPromocion(PromocionDTO dto) {
        Promocion promocion = convertToEntity(dto);
        Promocion saved = promocionRepository.save(promocion);
        return convertToDTO(saved);
    }

    @Transactional
    public PromocionDTO updatePromocion(Integer id, PromocionDTO dto) {
        Promocion existing = promocionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Promoción no encontrada"));
        
        existing.setNombre(dto.getNombre());
        existing.setDescripcion(dto.getDescripcion());
        existing.setPorcentajeDescuento(dto.getPorcentajeDescuento());
        existing.setFechaInicio(dto.getFechaInicio());
        existing.setFechaFin(dto.getFechaFin());
        existing.setActivo(dto.getActivo());
        
        Promocion updated = promocionRepository.save(existing);
        return convertToDTO(updated);
    }

    @Transactional
    public void deletePromocion(Integer id) {
        promocionRepository.deleteById(id);
    }

    @Transactional
    public PromocionProductoDTO asignarPromocionAProducto(Integer idPromocion, Integer idProducto) {

        Promocion promocion = promocionRepository.findById(idPromocion)
                .orElseThrow(() -> new RuntimeException("Promoción no encontrada"));

        Producto producto = productoRepository.findById(idProducto)
                .orElseThrow(() -> new RuntimeException("Producto no encontrado"));

        BigDecimal precioBase = producto.getPrecio();

        BigDecimal descuento = promocion.getPorcentajeDescuento();

        BigDecimal precioPromocional = precioBase
                .multiply(BigDecimal.valueOf(100 - descuento.doubleValue()))
                .divide(BigDecimal.valueOf(100));

        PromocionProducto pp = new PromocionProducto();
        pp.setPromocion(promocion);
        pp.setIdProducto(idProducto);
        pp.setPrecioPromocional(precioPromocional);

        PromocionProducto saved = promocionProductoRepository.save(pp);

        PromocionProductoDTO dto = new PromocionProductoDTO();
        dto.setIdPromocionProducto(saved.getIdPromocionProducto());
        dto.setIdPromocion(promocion.getIdPromocion());
        dto.setIdProducto(idProducto);
        dto.setPrecioPromocional(precioPromocional);

        return dto;
    }

    @Transactional
    public void desasociarPromocionDeProducto(Integer idPromocion, Integer idProducto) {

        log.info("Desasociando promoción {} del producto {}", idPromocion, idProducto);

        PromocionProducto relacion = promocionProductoRepository
                .findByPromocion_IdPromocionAndIdProducto(idPromocion, idProducto)
                .orElseThrow(() -> new RuntimeException("Relación promoción-producto no encontrada"));

        promocionProductoRepository.delete(relacion);
    }

    private PromocionDTO convertToDTO(Promocion p) {
        PromocionDTO dto = new PromocionDTO();
        dto.setIdPromocion(p.getIdPromocion());
        dto.setNombre(p.getNombre());
        dto.setDescripcion(p.getDescripcion());
        dto.setPorcentajeDescuento(p.getPorcentajeDescuento());
        dto.setFechaInicio(p.getFechaInicio());
        dto.setFechaFin(p.getFechaFin());
        dto.setActivo(p.getActivo());
        dto.setFechaCreacion(p.getFechaCreacion());
        return dto;
    }

    private Promocion convertToEntity(PromocionDTO dto) {
        Promocion p = new Promocion();
        p.setNombre(dto.getNombre());
        p.setDescripcion(dto.getDescripcion());
        p.setPorcentajeDescuento(dto.getPorcentajeDescuento());
        p.setFechaInicio(dto.getFechaInicio());
        p.setFechaFin(dto.getFechaFin());
        p.setActivo(dto.getActivo());
        return p;
    }
}