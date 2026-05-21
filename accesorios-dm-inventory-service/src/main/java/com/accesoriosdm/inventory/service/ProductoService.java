package com.accesoriosdm.inventory.service;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.accesoriosdm.inventory.dto.CategoriaDTO;
import com.accesoriosdm.inventory.dto.ImagenProductoDTO;
import com.accesoriosdm.inventory.dto.MaterialDTO;
import com.accesoriosdm.inventory.dto.ProductoDTO;
import com.accesoriosdm.inventory.dto.ProductoResumenDTO;
import com.accesoriosdm.inventory.dto.PromocionDTO;
import com.accesoriosdm.inventory.entity.Categoria;
import com.accesoriosdm.inventory.entity.ImagenProducto;
import com.accesoriosdm.inventory.entity.Material;
import com.accesoriosdm.inventory.entity.Producto;
import com.accesoriosdm.inventory.entity.Promocion;
import com.accesoriosdm.inventory.exception.ResourceNotFoundException;
import com.accesoriosdm.inventory.repository.CategoriaRepository;
import com.accesoriosdm.inventory.repository.ImagenProductoRepository;
import com.accesoriosdm.inventory.repository.MaterialRepository;
import com.accesoriosdm.inventory.repository.ProductoRepository;
import com.accesoriosdm.inventory.repository.PromocionRepository;
import com.accesoriosdm.inventory.storage.StorageService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProductoService {

    private final ProductoRepository productoRepository;
    private final CategoriaRepository categoriaRepository;
    private final MaterialRepository materialRepository;
    private final ImagenProductoRepository imagenProductoRepository;
    private final PromocionRepository promocionRepository;
    private final StorageService storageService;

    @Value("${app.storage.images-path}")
    private String imagesPath;

    // =========================
    // LISTADOS
    // =========================

    @Transactional(readOnly = true)
    public List<ProductoResumenDTO> getAllProductos() {
        return productoRepository.findByEstadoTrue()
                .stream()
                .map(this::convertToResumenDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Page<ProductoResumenDTO> getAllProductosPaginado(Pageable pageable) {
        return productoRepository.findByEstadoTrue(pageable)
                .map(this::convertToResumenDTO);
    }

    @Transactional(readOnly = true)
    public ProductoDTO getProductoById(Integer id) {
        Producto producto = productoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Producto no encontrado con id: " + id));

        return convertToFullDTO(producto);
    }

    @Transactional(readOnly = true)
    public Page<ProductoResumenDTO> getProductosByCategoriaPaginado(Integer categoriaId, Pageable pageable) {
        return productoRepository
                .findByCategoriaIdCategoriaAndEstadoTrue(categoriaId, pageable)
                .map(this::convertToResumenDTO);
    }

    @Transactional(readOnly = true)
    public List<ProductoResumenDTO> getProductosByCategoria(Integer categoriaId) {
        return productoRepository.findByCategoriaIdCategoriaAndEstadoTrue(categoriaId)
                .stream()
                .map(this::convertToResumenDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ProductoResumenDTO> getProductosDisponibles() {
        return productoRepository.findProductosDisponibles()
                .stream()
                .map(this::convertToResumenDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ProductoResumenDTO> getProductosDisponiblesByCategoria(Integer categoriaId) {
        return productoRepository.findProductosDisponiblesByCategoria(categoriaId)
                .stream()
                .map(this::convertToResumenDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ProductoResumenDTO> searchProductosByNombre(String nombre) {
        return productoRepository.findByNombreContainingIgnoreCase(nombre)
                .stream()
                .map(this::convertToResumenDTO)
                .collect(Collectors.toList());
    }

    // =========================
    // CRUD
    // =========================

    @Transactional
    public ProductoDTO createProducto(ProductoDTO request) {

        Categoria categoria = categoriaRepository.findById(request.getCategoria().getIdCategoria())
                .orElseThrow(() -> new ResourceNotFoundException("Categoría no encontrada"));

        Material material = materialRepository.findById(request.getMaterial().getIdMaterial())
                .orElseThrow(() -> new ResourceNotFoundException("Material no encontrado"));

        Producto producto = new Producto();
        producto.setNombre(request.getNombre());
        producto.setDescripcion(request.getDescripcion());
        producto.setPrecio(request.getPrecio());
        producto.setStock(request.getStock());
        Boolean estadoReq = request.getEstado();
        producto.setEstado(Boolean.TRUE.equals(estadoReq));
        producto.setCategoria(categoria);
        producto.setMaterial(material);

        Producto saved = productoRepository.save(producto);

        if (request.getImagenes() != null) {
            request.getImagenes().forEach(imgDTO -> {
                ImagenProducto img = new ImagenProducto();
                img.setUrlImagen(imgDTO.getUrlImagen());
                Integer orden = imgDTO.getOrden();
                img.setOrden(orden != null ? orden : 1);
                img.setProducto(saved);
                imagenProductoRepository.save(img);
            });
        }

        return convertToFullDTO(saved);
    }

    @Transactional
    public ProductoDTO updateProducto(Integer id, ProductoDTO request) {

        Producto producto = productoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Producto no encontrado"));

        Categoria categoria = categoriaRepository.findById(request.getCategoria().getIdCategoria())
                .orElseThrow(() -> new ResourceNotFoundException("Categoría no encontrada"));

        Material material = materialRepository.findById(request.getMaterial().getIdMaterial())
                .orElseThrow(() -> new ResourceNotFoundException("Material no encontrado"));

        producto.setNombre(request.getNombre());
        producto.setDescripcion(request.getDescripcion());
        producto.setPrecio(request.getPrecio());
        producto.setStock(request.getStock());
        Boolean estadoReq = request.getEstado();
        producto.setEstado(Boolean.TRUE.equals(estadoReq));
        producto.setCategoria(categoria);
        producto.setMaterial(material);

        return convertToFullDTO(productoRepository.save(producto));
    }

    @Transactional
    public void deleteProducto(Integer id) {
        Producto producto = productoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Producto no encontrado"));
        productoRepository.delete(producto);
    }

    // =========================
    // IMÁGENES
    // =========================

    @Transactional(readOnly = true)
    public List<ImagenProductoDTO> getImagenesByProducto(Integer productoId) {
        return imagenProductoRepository.findByProductoIdProductoOrderByOrdenAsc(productoId)
                .stream()
                .map(this::mapImagen)
                .collect(Collectors.toList());
    }

    @Transactional
    public ImagenProductoDTO addImagenToProducto(
            Integer productoId,
            MultipartFile file,
            Integer orden) {

        Producto producto = productoRepository.findById(productoId)
                .orElseThrow(() -> new ResourceNotFoundException("Producto no encontrado"));

        String imageUrl = storageService.saveProductImage(productoId, file);

        ImagenProducto img = new ImagenProducto();
        img.setUrlImagen(imageUrl);
        img.setOrden(orden != null ? orden : 1);
        img.setProducto(producto);

        ImagenProducto saved = imagenProductoRepository.save(img);

        return mapImagen(saved);
    }

    @Transactional
    public void deleteImagenFromProducto(Integer imagenId) {

        ImagenProducto imagen = imagenProductoRepository.findById(imagenId)
                .orElseThrow(() -> new ResourceNotFoundException("Imagen no encontrada"));

        storageService.deleteImage(imagen.getUrlImagen());

        imagenProductoRepository.delete(imagen);
    }
    
    @Transactional
    public ImagenProductoDTO uploadImagenProducto(
            Integer productoId,
            MultipartFile file,
            Integer orden) {

        try {

            Producto producto = productoRepository.findById(productoId)
                    .orElseThrow(() ->
                            new ResourceNotFoundException("Producto no encontrado"));

            // Crear carpeta del producto
            Path carpetaProducto = Paths.get(
                    imagesPath,
                    "productos",
                    productoId.toString()
            );

            Files.createDirectories(carpetaProducto);

            // Obtener extensión
            String nombreOriginal = file.getOriginalFilename();

            String extension = "";

            if (nombreOriginal != null && nombreOriginal.contains(".")) {
                extension = nombreOriginal.substring(
                        nombreOriginal.lastIndexOf(".")
                );
            }

            // Nombre único
            String nombreArchivo =
                    UUID.randomUUID() + extension;

            // Ruta final
            Path rutaArchivo =
                    carpetaProducto.resolve(nombreArchivo);

            // Guardar archivo
            Files.copy(
                    file.getInputStream(),
                    rutaArchivo,
                    StandardCopyOption.REPLACE_EXISTING
            );

            // URL pública
            String urlImagen =
                    "/uploads/productos/"
                            + productoId
                            + "/"
                            + nombreArchivo;

            // Guardar BD
            ImagenProducto imagen = new ImagenProducto();
            imagen.setProducto(producto);
            imagen.setUrlImagen(urlImagen);
            imagen.setOrden(orden != null ? orden : 1);

            ImagenProducto saved =
                    imagenProductoRepository.save(imagen);

            return mapImagen(saved);

        } catch (IOException e) {
            throw new RuntimeException("Error al guardar imagen", e);
        }
    }

    // =========================
    // DTO MAPPERS (FIX REAL DE NULLS)
    // =========================

    private ProductoResumenDTO convertToResumenDTO(Producto producto) {

        ProductoResumenDTO dto = new ProductoResumenDTO();
        dto.setIdProducto(producto.getIdProducto());
        dto.setNombre(producto.getNombre());
        dto.setPrecio(producto.getPrecio());

        List<ImagenProducto> imgs =
                imagenProductoRepository.findByProductoIdProductoOrderByOrdenAsc(producto.getIdProducto());

        if (!imgs.isEmpty()) {
            dto.setImagenPrincipal(imgs.get(0).getUrlImagen());
        }

        if (producto.getCategoria() != null) {
            dto.setCategoriaNombre(producto.getCategoria().getNombre());
        }

        dto.setPrecioConDescuento(calcularPrecioConDescuento(producto));

        return dto;
    }

    private ProductoDTO convertToFullDTO(Producto producto) {

        ProductoDTO dto = new ProductoDTO();

        dto.setIdProducto(producto.getIdProducto());
        dto.setNombre(producto.getNombre());
        dto.setDescripcion(producto.getDescripcion());
        dto.setPrecio(producto.getPrecio());
        dto.setStock(producto.getStock());
        dto.setFechaCreacion(producto.getFechaCreacion());
        dto.setEstado(producto.getEstado());

        // ✅ FIX COMPLETO CATEGORIA (evita nulls)
        if (producto.getCategoria() != null) {
            CategoriaDTO cat = new CategoriaDTO();
            cat.setIdCategoria(producto.getCategoria().getIdCategoria());
            cat.setNombre(producto.getCategoria().getNombre());
            cat.setDescripcion(producto.getCategoria().getDescripcion());
            cat.setEstado(producto.getCategoria().getEstado());
            dto.setCategoria(cat);
        }

        // ✅ FIX COMPLETO MATERIAL (evita nulls)
        if (producto.getMaterial() != null) {
            MaterialDTO mat = new MaterialDTO();
            mat.setIdMaterial(producto.getMaterial().getIdMaterial());
            mat.setNombre(producto.getMaterial().getNombre());
            mat.setDescripcion(producto.getMaterial().getDescripcion());
            dto.setMaterial(mat);
        }

        dto.setImagenes(getImagenesByProducto(producto.getIdProducto()));

        dto.setPrecioConDescuento(calcularPrecioConDescuento(producto));

        List<Promocion> promociones =
                promocionRepository.findPromocionesVigentesByProducto(producto.getIdProducto(), LocalDateTime.now());

        if (!promociones.isEmpty()) {
            Promocion p = promociones.get(0);

            PromocionDTO promoDTO = new PromocionDTO();
            promoDTO.setIdPromocion(p.getIdPromocion());
            promoDTO.setNombre(p.getNombre());
            promoDTO.setDescripcion(p.getDescripcion());
            promoDTO.setPorcentajeDescuento(p.getPorcentajeDescuento());
            promoDTO.setFechaInicio(p.getFechaInicio());
            promoDTO.setFechaFin(p.getFechaFin());
            promoDTO.setActivo(p.getActivo());
            promoDTO.setFechaCreacion(p.getFechaCreacion());

            dto.setPromocionActiva(promoDTO);
        }

        return dto;
    }

    private ImagenProductoDTO mapImagen(ImagenProducto img) {
        ImagenProductoDTO dto = new ImagenProductoDTO();
        dto.setIdImagen(img.getIdImagen());
        dto.setUrlImagen(img.getUrlImagen());
        dto.setOrden(img.getOrden());
        return dto;
    }

    // =========================
    // PROMOCIONES (CORRECTO ACTUAL)
    // =========================

    private BigDecimal calcularPrecioConDescuento(Producto producto) {

        List<Promocion> promociones =
                promocionRepository.findPromocionesVigentesByProducto(producto.getIdProducto(), LocalDateTime.now());

        if (promociones.isEmpty()) {
            return producto.getPrecio();
        }

        Promocion p = promociones.get(0);

        BigDecimal descuento = producto.getPrecio()
                .multiply(p.getPorcentajeDescuento())
                .divide(BigDecimal.valueOf(100));

        return producto.getPrecio().subtract(descuento);
    }
}