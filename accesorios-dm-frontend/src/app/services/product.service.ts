import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, catchError, map, of } from 'rxjs';

import { environment } from '../../environments/environment';
import { Product } from '../models/product.model';
import { ProductFactory } from '../factories/product.factory';

export interface Category {
  idCategoria: number;
  nombre: string;
}

export interface Material {
  idMaterial: number;
  nombre: string;
}

export interface CreateProductRequest {
  nombre: string;
  descripcion: string;
  precio: number;
  stock: number;
  categoria: { idCategoria: number };
  material: { idMaterial: number };
  estado: boolean;
}

export interface UpdateProductRequest extends CreateProductRequest {}

@Injectable({
  providedIn: 'root'
})
export class ProductService {
  private readonly apiUrl = `${environment.apiBaseUrl}/inventory/productos`;

  constructor(private readonly http: HttpClient) {}

  getProducts(): Observable<Product[]> {
    return this.http.get<any[]>(this.apiUrl).pipe(
      map((response) => ProductFactory.fromApiList(response)),
      catchError((error) => {
        console.error('Error al obtener productos:', error);
        return of([]);
      })
    );
  }

  getProductById(id: string): Observable<Product | null> {
    return this.http.get<any>(`${this.apiUrl}/${id}`).pipe(
      map((response) => ProductFactory.fromApi(response)),
      catchError((error) => {
        console.error('Error al obtener producto:', error);
        return of(null);
      })
    );
  }

  getCategories(): Observable<Category[]> {
    return this.http.get<Category[]>(
      `${environment.apiBaseUrl}/inventory/categorias`
    );
  }

  getMaterials(): Observable<Material[]> {
    return this.http.get<Material[]>(
      `${environment.apiBaseUrl}/inventory/materiales`
    );
  }

  createProduct(product: CreateProductRequest): Observable<any> {
    return this.http.post(this.apiUrl, product);
  }

  updateProduct(id: string, product: UpdateProductRequest): Observable<any> {
    return this.http.put(`${this.apiUrl}/${id}`, product);
  }

  uploadProductImage(productId: string, file: File): Observable<any> {
    const formData = new FormData();
    formData.append('file', file);

    return this.http.post(
      `${this.apiUrl}/${productId}/imagenes/upload`,
      formData
    );
  }

  deleteProduct(id: string): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${id}`);
  }
}