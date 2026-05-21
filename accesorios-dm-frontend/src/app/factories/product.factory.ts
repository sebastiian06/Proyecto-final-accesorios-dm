import { Product } from '../models/product.model';

const API_BASE = 'http://localhost:8000/api/v1';

function resolveImage(data: any): string {
  const image =
    data.imagenPrincipal ??
    data.imagenUrl ??
    data.imageUrl ??
    data.urlImagen ??
    data.imagenes?.[0]?.urlImagen ??
    '';

  if (!image) return 'https://placehold.co/300x200?text=Producto';
  if (image.startsWith('data:image')) return image;
  if (image.startsWith('http')) return image;

  return `${API_BASE}${image}`;
}

export class ProductFactory {
  static fromApi(data: any): Product {
    return {
  id: String(data.idProducto ?? data.id ?? data.productoId ?? ''),
  name: data.nombre ?? data.name ?? 'Producto sin nombre',
  description: data.descripcion ?? data.description ?? '',
  price: Number(data.precioConDescuento ?? data.precio ?? data.price ?? 0),
  originalPrice: data.precioConDescuento ? Number(data.precio) : undefined,
  discountPercentage: data.promocionActiva?.porcentajeDescuento,
  promotionName: data.promocionActiva?.nombre,
  stock: Number(data.stock ?? data.stockDisponible ?? data.cantidad ?? 0),
  imageUrl: resolveImage(data),
  category:
    data.categoria?.nombre ??
    data.categoriaNombre ??
    data.category ??
    '',
  material:
    data.material?.nombre ??
    data.materialNombre ??
    data.material ??
    ''
};
  }

  static fromApiList(data: any[]): Product[] {
    return data.map((item) => this.fromApi(item));
  }
}