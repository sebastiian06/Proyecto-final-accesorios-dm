import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import { Product } from '../models/product.model';

export interface CartItem {
  product: Product;
  quantity: number;
}

@Injectable({ providedIn: 'root' })
export class CartService {
  private readonly storageKey = 'cart';
  private readonly itemsSubject = new BehaviorSubject<CartItem[]>(this.loadFromStorage());
  items$ = this.itemsSubject.asObservable();

  private readonly drawerOpenSubject = new BehaviorSubject<boolean>(false);
  drawerOpen$ = this.drawerOpenSubject.asObservable();

  getItems(): CartItem[] {
    return this.itemsSubject.value;
  }

  addProduct(product: Product): void {
    const items = this.itemsSubject.value;
    const existingItem = items.find((item) => item.product.id === product.id);

    if (existingItem) {
      existingItem.quantity += 1;
      this.updateItems([...items]);
    } else {
      this.updateItems([...items, { product, quantity: 1 }]);
    }

    this.openDrawer();
  }

  increaseProduct(productId: string): void {
    const items = this.itemsSubject.value.map((item) =>
      item.product.id === productId
        ? { ...item, quantity: item.quantity + 1 }
        : item
    );

    this.updateItems(items);
  }

  decreaseProduct(productId: string): void {
    const items = this.itemsSubject.value
      .map((item) =>
        item.product.id === productId
          ? { ...item, quantity: item.quantity - 1 }
          : item
      )
      .filter((item) => item.quantity > 0);

    this.updateItems(items);
  }

  removeProduct(productId: string): void {
    const items = this.itemsSubject.value.filter(
      (item) => item.product.id !== productId
    );

    this.updateItems(items);
  }

  clearCart(): void {
    this.updateItems([]);
  }

  getTotal(): number {
    return this.itemsSubject.value.reduce(
      (total, item) => total + item.product.price * item.quantity,
      0
    );
  }

  getCount(): number {
    return this.itemsSubject.value.reduce(
      (total, item) => total + item.quantity,
      0
    );
  }

  openDrawer(): void {
    this.drawerOpenSubject.next(true);
  }

  closeDrawer(): void {
    this.drawerOpenSubject.next(false);
  }

  private updateItems(items: CartItem[]): void {
    this.itemsSubject.next(items);
    localStorage.setItem(this.storageKey, JSON.stringify(items));
  }

  private loadFromStorage(): CartItem[] {
    const storedCart = localStorage.getItem(this.storageKey);

    if (!storedCart) {
      return [];
    }

    try {
      return JSON.parse(storedCart) as CartItem[];
    } catch {
      localStorage.removeItem(this.storageKey);
      return [];
    }
  }
}