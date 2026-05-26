# Auditoría de Imágenes y Iconos de Red (Network/Cached)

Este archivo lista las imágenes que se cargan desde URLs de red en el aplicativo. Puedes reemplazarlas por recursos locales en la carpeta `assets/images/` para mejorar sustancialmente el rendimiento de carga inicial y evitar parpadeos/lag.

## 1. Iconos y Avatares de Usuario
| Nombre / Componente | URL de Red por Defecto | Archivo en Código | Propósito / Uso |
| --- | --- | --- | --- |
| **Avatar de Usuario por Defecto** | `https://www.w3schools.com/howto/img_avatar.png` | [profile_bloc.dart](file:///c:/Users/LENOVO/OneDrive/Desktop/Proyect/trim_flow/lib/features/profile/presentation/bloc/profile_bloc.dart#L124) | Imagen de perfil mostrada en el panel cuando el usuario no tiene configurado un avatar en Supabase o Google. |

## 2. Imágenes de Inicio y Banner Principal (Home Hero)
| Nombre / Componente | URL de Red por Defecto | Archivo en Código | Propósito / Uso |
| --- | --- | --- | --- |
| **Imagen de Fondo Hero** | `https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800` | [home_content.dart](file:///c:/Users/LENOVO/OneDrive/Desktop/Proyect/trim_flow/lib/features/home/domain/models/home_content.dart#L11) | Imagen de banner principal con temática de barbería de alta resolución en la cabecera. |
| **Imagen Sobre Nosotros** | `https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800` | [home_content.dart](file:///c:/Users/LENOVO/OneDrive/Desktop/Proyect/trim_flow/lib/features/home/domain/models/home_content.dart#L19) | Imagen de fondo de la sección de información "Sobre Nosotros". |

## 3. Historias / Looks Destacados (Stories Bar)
| Nombre / Componente | URL de Red por Defecto | Archivo en Código | Propósito / Uso |
| --- | --- | --- | --- |
| **Look 1 (Classic Slick)** | `https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=800` | [home_repository_impl.dart](file:///c:/Users/LENOVO/OneDrive/Desktop/Proyect/trim_flow/lib/features/home/data/repositories/home_repository_impl.dart#L13) | Imagen de vista previa de look/estilo en la barra de historias (Stories). |
| **Look 2 (Modern Crop)** | `https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800` | [home_repository_impl.dart](file:///c:/Users/LENOVO/OneDrive/Desktop/Proyect/trim_flow/lib/features/home/data/repositories/home_repository_impl.dart#L14) | Imagen de vista previa del segundo look de barbería en historias. |
| **Look 3 (Sharp Pompadour)** | `https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=800` | [home_repository_impl.dart](file:///c:/Users/LENOVO/OneDrive/Desktop/Proyect/trim_flow/lib/features/home/data/repositories/home_repository_impl.dart#L15) | Imagen de vista previa de look en la barra superior. |
| **Look 4 (Fade & Beard)** | `https://images.unsplash.com/photo-1512690196252-741ef2ae7626?w=800` | [home_repository_impl.dart](file:///c:/Users/LENOVO/OneDrive/Desktop/Proyect/trim_flow/lib/features/home/data/repositories/home_repository_impl.dart#L16) | Imagen de vista previa de look en la barra superior. |

## 4. Servicios del Grid (Home Services Grid)
| Nombre / Componente | URL de Red por Defecto | Archivo en Código | Propósito / Uso |
| --- | --- | --- | --- |
| **Corte Clásico** | `https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800` | [home_repository_impl.dart](file:///c:/Users/LENOVO/OneDrive/Desktop/Proyect/trim_flow/lib/features/home/data/repositories/home_repository_impl.dart#L19) | Imagen de tarjeta del servicio "Corte Clásico". |
| **Barba Luxury** | `https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=800` | [home_repository_impl.dart](file:///c:/Users/LENOVO/OneDrive/Desktop/Proyect/trim_flow/lib/features/home/data/repositories/home_repository_impl.dart#L20) | Imagen de tarjeta del servicio "Barba Luxury". |
| **TrimFlow Special** | `https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=800` | [home_repository_impl.dart](file:///c:/Users/LENOVO/OneDrive/Desktop/Proyect/trim_flow/lib/features/home/data/repositories/home_repository_impl.dart#L21) | Imagen de tarjeta de servicio especial de la casa. |
| **Limpieza Facial** | `https://images.unsplash.com/photo-1621605815841-2dddbaa20b2a?w=800` | [home_repository_impl.dart](file:///c:/Users/LENOVO/OneDrive/Desktop/Proyect/trim_flow/lib/features/home/data/repositories/home_repository_impl.dart#L22) | Imagen de tarjeta del servicio "Limpieza Facial". |

## 5. Productos Destacados (Products Grid)
| Nombre / Componente | URL de Red por Defecto | Archivo en Código | Propósito / Uso |
| --- | --- | --- | --- |
| **Cera Modeladora Pomade** | `https://images.unsplash.com/photo-1590159443202-05459341777d?w=800` | [home_repository_impl.dart](file:///c:/Users/LENOVO/OneDrive/Desktop/Proyect/trim_flow/lib/features/home/data/repositories/home_repository_impl.dart#L29) | Imagen de producto para peinado de barba/cabello. |
| **Aceite Premium para Barba** | `https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=800` | [home_repository_impl.dart](file:///c:/Users/LENOVO/OneDrive/Desktop/Proyect/trim_flow/lib/features/home/data/repositories/home_repository_impl.dart#L35) | Imagen de producto de hidratación capilar y facial. |
| **Shampoo Anticaída** | `https://images.unsplash.com/photo-1621605815841-2dddbaa20b2a?w=800` | [home_repository_impl.dart](file:///c:/Users/LENOVO/OneDrive/Desktop/Proyect/trim_flow/lib/features/home/data/repositories/home_repository_impl.dart#L41) | Imagen de producto de higiene y cuidado capilar. |
| **Navaja de Afeitar Profesional** | `https://images.unsplash.com/photo-1634480251976-88062030061e?w=800` | [home_repository_impl.dart](file:///c:/Users/LENOVO/OneDrive/Desktop/Proyect/trim_flow/lib/features/home/data/repositories/home_repository_impl.dart#L47) | Imagen de herramienta de afeitar profesional. |

---
*Nota: Para cambiar estas imágenes por locales, agrega los archivos `.png` o `.jpg` a tu carpeta `assets/images/`, regístralos en tu `pubspec.yaml` bajo `assets:`, y reemplaza las cadenas `https://...` en los archivos mencionados arriba por `"assets/images/nombre_archivo.png"`.*
