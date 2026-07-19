pub mod app;
pub mod config;
pub mod engine_bindings;
pub mod update;

use eframe::NativeOptions;

fn main() -> eframe::Result<()> {
    let options = NativeOptions {
        viewport: egui::ViewportBuilder::default()
            .with_inner_size([1100.0, 720.0])
            .with_title("Otter - Local Engine")
            .with_icon(
                egui::load_icon_bytes(
                    include_bytes!("../assets/logo.png"),
                )
                .ok(),
            ),
        ..Default::default()
    };
    eframe::run_native(
        "Otter - Local Engine",
        options,
        Box::new(|cc| Box::new(app::OtterApp::new(cc))),
    )
}
