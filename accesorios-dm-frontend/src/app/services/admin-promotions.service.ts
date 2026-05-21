import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface Promotion {
  idPromocion: number;
  nombre: string;
  descripcion: string;
  porcentajeDescuento: number;
  fechaInicio: string;
  fechaFin: string;
  activo: boolean;
}

export interface PromotionRequest {
  nombre: string;
  descripcion: string;
  porcentajeDescuento: number;
  fechaInicio: string;
  fechaFin: string;
  activo: boolean;
}

@Injectable({
  providedIn: 'root'
})
export class AdminPromotionsService {
 private readonly apiUrl = `${environment.apiBaseUrl}/inventory/promociones`;

  constructor(private readonly http: HttpClient) {}

  getPromotions(): Observable<Promotion[]> {
    return this.http.get<Promotion[]>(this.apiUrl);
  }

  createPromotion(promotion: PromotionRequest): Observable<Promotion> {
    return this.http.post<Promotion>(this.apiUrl, promotion);
  }

  updatePromotion(id: number, promotion: PromotionRequest): Observable<Promotion> {
    return this.http.put<Promotion>(`${this.apiUrl}/${id}`, promotion);
  }

  deletePromotion(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }

  assignPromotionToProduct(promotionId: number, productId: number): Observable<any> {
  return this.http.post(
    `${this.apiUrl}/${promotionId}/productos/${productId}`,
    {}
  );
}

  removePromotionFromProduct(promotionId: number, productId: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${promotionId}/productos/${productId}`);
  }
}