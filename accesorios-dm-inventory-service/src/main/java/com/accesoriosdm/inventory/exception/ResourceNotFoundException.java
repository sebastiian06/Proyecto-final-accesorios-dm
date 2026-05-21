package com.accesoriosdm.inventory.exception;

public class ResourceNotFoundException extends RuntimeException {
    
    public ResourceNotFoundException(String message) {
        super(message);
    }
    
    public ResourceNotFoundException(String message, Throwable cause) {
        super(message, cause);
    }

    public static void main(String[] args) {
        System.out.println("ResourceNotFoundException class");
    }
}