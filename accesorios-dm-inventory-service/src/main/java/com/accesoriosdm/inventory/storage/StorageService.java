package com.accesoriosdm.inventory.storage;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class StorageService {

    @Value("${app.storage.images-path}")
    private String imagesPath;

    public String saveProductImage(Integer productoId, MultipartFile file) {

        try {

            String originalName = file.getOriginalFilename();

            String extension = "";

            if (originalName != null && originalName.contains(".")) {
                extension = originalName.substring(originalName.lastIndexOf("."));
            }

            String fileName = UUID.randomUUID() + extension;

            Path productFolder = Paths.get(imagesPath, "producto-" + productoId);

            if (!Files.exists(productFolder)) {
                Files.createDirectories(productFolder);
            }

            Path destination = productFolder.resolve(fileName);

            Files.copy(
                    file.getInputStream(),
                    destination,
                    StandardCopyOption.REPLACE_EXISTING
            );

            return "/uploads/producto-" + productoId + "/" + fileName;

        } catch (IOException e) {
            throw new RuntimeException("Error guardando imagen", e);
        }
    }

    public void deleteImage(String imageUrl) {

        try {

            String relativePath = imageUrl.replace("/uploads/", "");

            Path imagePath = Paths.get(imagesPath, relativePath);

            Files.deleteIfExists(imagePath);

        } catch (IOException e) {
            throw new RuntimeException("Error eliminando imagen", e);
        }
    }
}