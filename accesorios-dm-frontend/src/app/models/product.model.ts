export interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  originalPrice?: number;
  discountPercentage?: number;
  promotionName?: string;
  stock: number;
  imageUrl: string;
  category?: string;
  material?: string;
}