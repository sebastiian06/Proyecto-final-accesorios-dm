import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';

import { CartService } from '../../services/cart.service';
import { Product } from '../../models/product.model';
import { ProductService } from '../../services/product.service';

@Component({
  selector: 'app-product-detail',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './product-detail.component.html',
  styleUrl: './product-detail.component.css'
})
export class ProductDetailComponent implements OnInit {
  product: Product | null = null;
  isLoading = true;
  errorMessage = '';
  quantity = 1;
  showCartMessage = false;

  constructor(
    private readonly route: ActivatedRoute,
    private readonly productService: ProductService,
    private readonly cartService: CartService
  ) {}

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');

    if (!id) {
      this.errorMessage = 'No se encontró el producto seleccionado.';
      this.isLoading = false;
      return;
    }

    this.productService.getProductById(id).subscribe({
      next: (product) => {
        this.product = product;
        this.isLoading = false;

        if (!product) {
          this.errorMessage = 'No fue posible cargar el detalle del producto.';
        }
      },
      error: () => {
        this.errorMessage = 'No fue posible cargar el detalle del producto.';
        this.isLoading = false;
      }
    });
  }

  get imageUrl(): string {
    return this.product?.imageUrl || 'https://placehold.co/600x480?text=Producto';
  }

  increaseQuantity(): void {
    this.quantity += 1;
  }

  decreaseQuantity(): void {
    if (this.quantity > 1) {
      this.quantity -= 1;
    }
  }

  addToCart(): void {
  if (!this.product) {
    return;
  }

  for (let i = 0; i < this.quantity; i++) {
    this.cartService.addProduct(this.product);
  }

  this.showCartMessage = true;

  setTimeout(() => {
    this.showCartMessage = false;
  }, 2500);
}
}