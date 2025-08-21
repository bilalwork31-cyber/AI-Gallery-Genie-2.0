# AI Gallery Genie 🖼️✨

A Flutter-based AI-powered photo gallery app with advanced local processing capabilities for privacy-focused photo management and editing.

![AI Gallery Genie](aI%20gALLERY%20gENIE(2).jpg)

## 🚀 Features

### 📸 **Photo Classification**
- **UNet Model**: Advanced image segmentation and classification
- **FaceNet Integration**: Facial recognition and clustering
- Smart photo organization and tagging

### 🔍 **Object Detection**
- **Google MediaPipe**: Real-time object detection and tracking
- Identify and label objects, people, and scenes
- Enhanced search and filtering capabilities

### 🎨 **AI Photo Editing**
- **Stable Diffusion**: Advanced AI-powered image editing
- Background removal and replacement
- Style transfer and enhancement
- Inpainting and restoration

## 💳 Credit System

- **Stripe Integration**: Secure payment processing
- **Credit-based Usage**: Pay-per-edit model
- Track usage and manage credits efficiently

## 🔒 Privacy First

- **100% Local Processing**: All AI models run locally
- **No Cloud Upload**: Your photos never leave your device
- **Runtime Libraries**: Efficient local model execution
- Complete privacy and data control

## 📱 Screenshots

| Gallery View | AI Editing | Object Detection |
|--------------|------------|------------------|
| ![Gallery](images/aI%20gALLERY%20gENIE(2).jpg) | ![Editing](images/aI%20gALLERY%20gENIE(2).jpg) | ![Detection](images/aI%20gALLERY%20gENIE(2).jpg) |

## 🛠️ Tech Stack

- **Framework**: Flutter
- **AI Models**: UNet, FaceNet, MediaPipe, Stable Diffusion
- **Payment**: Stripe API
- **Local Processing**: Runtime libraries for model execution
- **State Management**: Provider pattern

## 🏃‍♂️ Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/bilalwork31-cyber/AI-Gallery-Genie.git
   cd AI-Gallery-Genie
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── Model/                 # Data models and providers
│   ├── GalleryProvider.dart
│   ├── ImagelabelingProvider.dart
│   ├── payment_provider.dart
│   └── ...
├── Model-View/           # UI screens and components
│   ├── GalleryHome.dart
│   ├── bg_remover.dart
│   ├── upscaling.dart
│   └── ...
└── main.dart            # App entry point
```

## ⚙️ Configuration

1. **Stripe Setup**: Add your Stripe keys in `lib/Model/payment_provider.dart`
2. **Model Assets**: Ensure AI models are placed in the `assets/models/` directory
3. **Permissions**: Configure camera and storage permissions in platform-specific files

## 🔧 Features in Detail

### AI Classification
- Automatic photo tagging using UNet architecture
- Face clustering with FaceNet for person-based organization
- Smart albums based on AI analysis

### Object Detection
- Real-time detection using Google MediaPipe
- Support for 80+ object categories
- Bounding box visualization and confidence scores

### Photo Editing
- Stable Diffusion-powered editing tools
- Background removal and replacement
- Image upscaling and enhancement
- Inpainting for object removal

## 💰 Credit System
- Purchase credits via Stripe integration
- Different credit costs for various AI operations
- Track usage history and remaining balance

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

**Built with ❤️ for privacy-conscious photo enthusiasts**
