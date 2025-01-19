import customtkinter as ctk
from tkinter import filedialog, Canvas, Frame  # ttk
from PIL import Image, ImageOps, ImageEnhance, ImageTk
import numpy as np


class Milkifier(ctk.CTk):
    # noinspection PyTypeChecker
    def __init__(self):
        super().__init__()
        self.y = None
        self.x = None
        self.title("MilkUP - Image Milkifier")
        self.geometry("572x729")
        self.resizable(False, False)
        self.overrideredirect(True)
        self.attributes('-topmost', True)

        ctk.set_appearance_mode('dark')
        ctk.set_default_color_theme('blue')
        c_font = ctk.CTkFont('Courier New', 18)

        self.title_bar = Frame(self, bg="#0D0D14", height=16)
        self.title_bar.grid(row=0, column=0, columnspan=3, sticky="nsew")
        self.title_bar.bind("<Button-1>", self.start_move)
        self.title_bar.bind("<B1-Motion>", self.on_move)
        self.title_bar.bind("<ButtonRelease-1>", self.stop_move)

        self.title_label = ctk.CTkLabel(self.title_bar, text="")
        self.title_label.pack(side="left")
        self.title_label.bind("<Button-1>", self.start_move)
        self.title_label.bind("<B1-Motion>", self.on_move)

        self.close_button = ctk.CTkButton(
            self.title_bar, text="⮽", width=15, height=15, font=("Courier New", 22), command=self.destroy,
            fg_color="#0D0D14", text_color="#52263E")
        self.close_button.pack(side="right", padx=(0, 1), pady=(5, 1))
        self.close_button.bind("<Enter>", self.on_hover_close)
        self.close_button.bind("<Leave>", self.on_leave_close)

        self.image_path = None
        self.image = None
        self.original_image = None
        self.preview_image = None
        self.palette = [(13, 13, 20), (82, 38, 62), (172, 51, 50)]

        self.canvas = Canvas(self, width=500, height=500, bg="#52263E", highlightthickness=0)
        self.canvas.grid(row=1, column=0, columnspan=3, pady=(0, 5), padx=20)

        self.load_button = ctk.CTkButton(self, text="Load Image", command=self.load_image, font=c_font)
        self.load_button.grid(row=5, column=0, pady=5, padx=(36, 0))

        self.brightness_label = ctk.CTkLabel(self, text="Brightness", font=c_font)
        self.brightness_label.grid(row=3, column=0, pady=5, sticky="w", padx=(36, 0))

        self.brightness_slider = ctk.CTkSlider(self, from_=0.1, to=2, command=self.adjust_brightness)
        self.brightness_slider.set(1)
        self.brightness_slider.grid(row=3, column=1, pady=5, sticky="ew")

        self.brightness_counter = ctk.CTkLabel(self, text="50", font=c_font)
        self.brightness_counter.grid(row=3, column=2, pady=5, sticky="e", padx=(0, 36))

        self.contrast_label = ctk.CTkLabel(self, text="Contrast", font=c_font)
        self.contrast_label.grid(row=4, column=0, pady=5, sticky="w", padx=(36, 0))

        self.contrast_slider = ctk.CTkSlider(self, from_=0.1, to=2, command=self.adjust_contrast)
        self.contrast_slider.set(1)
        self.contrast_slider.grid(row=4, column=1, pady=5, sticky="ew")

        self.contrast_counter = ctk.CTkLabel(self, text="50", font=c_font)
        self.contrast_counter.grid(row=4, column=2, pady=5, sticky="e", padx=(0, 36))

        self.grayscale_button = ctk.CTkButton(self, text="Grayscale", command=self.apply_grayscale, font=c_font)
        self.grayscale_button.grid(row=5, column=1, pady=5, padx=20)

        self.posterize_button = ctk.CTkButton(self, text="Posterize", command=self.apply_posterize, font=c_font)
        self.posterize_button.grid(row=5, column=2, pady=5, padx=(0, 36))

        self.color_index_button = ctk.CTkButton(self, text="Pilkify [FAST]", command=self.apply_color_indexing_small,
                                                font=('Courier New', 15))
        self.color_index_button.grid(row=6, column=0, pady=5, padx=(36, 0))

        self.color_index_button = ctk.CTkButton(self, text="Milkify [SLOW]", command=self.apply_color_indexing,
                                                font=('Courier New', 15))
        self.color_index_button.grid(row=6, column=1, pady=5, padx=20)

        self.save_button = ctk.CTkButton(self, text="Save Image", command=self.save_image, font=c_font)
        self.save_button.grid(row=6, column=2, columnspan=3, pady=10, padx=(0, 36))

        # self.pixelize_button = ctk.CTkButton(self, text="Pixelize", command=self.apply_pixelize, font=c_font)
        # self.pixelize_button.grid(row=5, column=2, pady=5, padx=(0, 25))

        self.grid_columnconfigure(1, weight=1)

    def load_image(self):
        file_path = filedialog.askopenfilename(filetypes=[("Image Files", "*.png;*.jpg;*.jpeg")])
        if file_path:
            self.image_path = file_path
            self.image = Image.open(file_path).convert("RGB")
            self.original_image = self.image.copy()
            self.update_preview()

    def update_preview(self):
        if self.image:
            max_canvas_width = 500
            max_canvas_height = 500

            img_width, img_height = self.image.size

            scaling_factor = min(max_canvas_width / img_width, max_canvas_height / img_height, 1)

            display_width = int(img_width * scaling_factor)
            display_height = int(img_height * scaling_factor)
            resized_image = self.image.resize((display_width, display_height), Image.Resampling.LANCZOS)

            self.canvas.config(width=display_width, height=display_height)

            current_window_width = self.winfo_width()
            new_window_height = max(300, display_height + 229)
            self.geometry(f"{current_window_width}x{new_window_height}")

            self.preview_image = ImageTk.PhotoImage(resized_image)
            self.canvas.delete("all")
            self.canvas.create_image(0, 0, anchor="nw", image=self.preview_image)

    def reset_image(self):
        if self.original_image:
            self.image = self.original_image.copy()

    def apply_grayscale(self):
        if self.image:
            self.image = ImageOps.grayscale(self.image).convert("RGB")
            self.update_preview()

    # def apply_pixelize(self):
    #    if self.image:
    #        scaled_image = self.image.resize((360, 360), Image.Resampling.NEAREST)

    #        pixelized_image = scaled_image.resize(self.image.size, Image.Resampling.NEAREST)

    #        self.image = pixelized_image
    #        self.update_preview()

    def adjust_brightness(self, value):
        if self.image:
            self.reset_image()

            contrast_value = self.contrast_slider.get()

            self.image = ImageEnhance.Contrast(self.image).enhance(contrast_value)
            self.image = ImageEnhance.Brightness(self.image).enhance(float(value))
            self.update_preview()

        brightness_level = int((float(value) - 0.1) / 1.9 * 100)
        self.brightness_counter.configure(text=str(brightness_level))

    def adjust_contrast(self, value):
        if self.image:
            self.reset_image()

            brightness_value = self.brightness_slider.get()

            self.image = ImageEnhance.Brightness(self.image).enhance(brightness_value)
            self.image = ImageEnhance.Contrast(self.image).enhance(float(value))
            self.update_preview()  # made by rxssxr https://discord.gg/bhDJpxM

        contrast_level = int((float(value) - 0.1) / 1.9 * 100)
        self.contrast_counter.configure(text=str(contrast_level))

    def apply_posterize(self):
        if self.image:
            self.image = ImageOps.posterize(self.image, 3)
            self.update_preview()

    def apply_color_indexing(self):
        if self.image:
            img_array = np.array(self.image)
            h, w, k = img_array.shape

            flat_pixels = img_array.reshape(-1, 3)

            indexed_pixels = np.array([
                min(self.palette, key=lambda c: np.linalg.norm(c - pixel))
                for pixel in flat_pixels
            ], dtype=np.uint8)

            indexed_image = indexed_pixels.reshape(h, w, 3)

            self.image = Image.fromarray(indexed_image, "RGB")
            self.update_preview()

    def apply_color_indexing_small(self):
        if self.image:
            small_image = self.image.resize((360, 360), Image.Resampling.LANCZOS)
            img_array = np.array(small_image)
            h, w, c = img_array.shape
            flat_pixels = img_array.reshape(-1, 3)
            palette_array = np.array(self.palette)
            distances = np.linalg.norm(flat_pixels[:, None] - palette_array[None, :], axis=2)
            closest_colors = palette_array[np.argmin(distances, axis=1)]
            indexed_pixels = closest_colors.reshape(h, w, 3).astype(np.uint8)
            indexed_image = Image.fromarray(indexed_pixels, "RGB").resize(self.image.size, Image.Resampling.NEAREST)
            self.image = indexed_image
        self.update_preview()

    def save_image(self):
        if self.image:
            save_path = filedialog.asksaveasfilename(defaultextension=".png",
                                                     filetypes=[("PNG Files", "*.png"), ("JPEG Files", "*.jpg")])

            if save_path:
                self.image.save(save_path)

    def start_move(self, event):
        self.x = event.x
        self.y = event.y

    def on_move(self, event):
        deltax = event.x - self.x
        deltay = event.y - self.y
        self.geometry(f"+{self.winfo_x() + deltax}+{self.winfo_y() + deltay}")

    def stop_move(self, event):
        self.x = None
        self.y = None

    def on_hover_close(self, event):
        self.close_button.configure(text_color="#AC3332")

    def on_leave_close(self, event):
        self.close_button.configure(text_color="#52263E")


if __name__ == "__main__":
    app = Milkifier()
    app.mainloop()  # made by rxssxr https://discord.gg/bhDJpxM
