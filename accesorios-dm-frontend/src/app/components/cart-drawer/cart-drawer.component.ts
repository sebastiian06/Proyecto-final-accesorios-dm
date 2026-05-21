import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';

import { CartItem, CartService } from '../../services/cart.service';

@Component({
  selector: 'app-cart-drawer',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './cart-drawer.component.html',
  styleUrl: './cart-drawer.component.css'
})
export class CartDrawerComponent {
  items: CartItem[] = [];
  isOpen = false;

  constructor(private readonly cartService: CartService) {
    this.cartService.items$.subscribe((items) => {
      this.items = items;
    });

    this.cartService.drawerOpen$.subscribe((isOpen) => {
      this.isOpen = isOpen;
    });
  }

  close(): void {
    this.cartService.closeDrawer();
  }

  remove(productId: string): void {
    this.cartService.removeProduct(productId);
  }

  get total(): number {
    return this.cartService.getTotal();
  }
  increase(productId: string): void {
  this.cartService.increaseProduct(productId);
}

decrease(productId: string): void {
  this.cartService.decreaseProduct(productId);
}
}