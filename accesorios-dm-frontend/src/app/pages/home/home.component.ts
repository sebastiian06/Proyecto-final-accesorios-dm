import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { RouterLink } from '@angular/router';

import { Product } from '../../models/product.model';
import { CartService } from '../../services/cart.service';
import { ProductService } from '../../services/product.service';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './home.component.html',
  styleUrl: './home.component.css'
})
export class HomeComponent implements OnInit {
  products: Product[] = [];
  cartCount = 0;

  categories = [
    { name: 'Todo', path: '/catalogo' },
    { name: 'Collares', path: '/catalogo' },
    { name: 'Aretes', path: '/catalogo' },
    { name: 'Earcuff', path: '/catalogo' },
    { name: 'Pulseras', path: '/catalogo' },
    { name: 'Anillos', path: '/catalogo' },
    { name: 'Sets', path: '/catalogo' },
    { name: 'Best seller', path: '/catalogo' }
  ];

  constructor(
    private readonly productService: ProductService,
    private readonly cartService: CartService
  ) {}

  ngOnInit(): void {
    this.productService.getProducts().subscribe({
      next: (products) => {
        this.products = products.slice(0, 4);
      }
    });

    this.cartService.items$.subscribe(() => {
      this.cartCount = this.cartService.getCount();
    });
  }

  addToCart(event: Event, product: Product): void {
    event.stopPropagation();
    this.cartService.addProduct(product);
  }
}