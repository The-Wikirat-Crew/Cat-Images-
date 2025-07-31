package;

import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.events.Event;
import openfl.net.URLRequest;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.ui.Button;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.geom.Rectangle;
import openfl.media.Sound;
import openfl.media.SoundChannel;

import haxe.Json;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;

import sys.FileSystem;
import sys.io.File;

// Para la IA conversacional con Cloudflare Workers AI
// Necesitarías una librería Haxe para hacer peticiones HTTP a la API de Cloudflare.
// Por simplicidad, aquí se muestra una estructura básica de cómo se haría la petición.
// La implementación real de la IA requeriría una integración más profunda y manejo de respuestas.

class Main extends Sprite {

    private var catImage:Bitmap;
    private var generateButton:Button;
    private var saveButton:Button;
    private var aiResponseText:TextField;
    private var aiInput:TextField;
    private var sendAIButton:Button;

    private var currentCatImageUrl:String;

    public function new() {
        super();
        setupUI();
        loadCatImage();
    }

    private function setupUI():Void {
        var format:TextFormat = new TextFormat();
        format.size = 24;

        generateButton = new Button();
        generateButton.x = 50;
        generateButton.y = 50;
        generateButton.width = 200;
        generateButton.height = 50;
        generateButton.text = "Generar Michi";
        generateButton.addEventListener(Event.CLICK, onGenerateClick);
        addChild(generateButton);

        saveButton = new Button();
        saveButton.x = 50;
        saveButton.y = 120;
        saveButton.width = 200;
        saveButton.height = 50;
        saveButton.text = "Guardar Michi";
        saveButton.addEventListener(Event.CLICK, onSaveClick);
        addChild(saveButton);

        catImage = new Bitmap();
        catImage.x = 300;
        catImage.y = 50;
        addChild(catImage);

        aiInput = new TextField();
        aiInput.x = 50;
        aiInput.y = 200;
        aiInput.width = 200;
        aiInput.height = 50;
        aiInput.border = true;
        aiInput.text = "Pregunta a la IA...";
        addChild(aiInput);

        sendAIButton = new Button();
        sendAIButton.x = 50;
        sendAIButton.y = 270;
        sendAIButton.width = 200;
        sendAIButton.height = 50;
        sendAIButton.text = "Enviar a IA";
        sendAIButton.addEventListener(Event.CLICK, onSendAIClick);
        addChild(sendAIButton);

        aiResponseText = new TextField();
        aiResponseText.x = 300;
        aiResponseText.y = 300;
        aiResponseText.width = 400;
        aiResponseText.height = 150;
        aiResponseText.border = true;
        aiResponseText.wordWrap = true;
        aiResponseText.multiline = true;
        addChild(aiResponseText);
    }

    private function loadCatImage():Void {
        var request = new URLRequest("https://api.thecatapi.com/v1/images/search");
        var loader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.TEXT;
        loader.addEventListener(Event.COMPLETE, onCatImageLoaded);
        loader.load(request);
    }

    private function onCatImageLoaded(event:Event):Void {
        var loader:URLLoader = cast event.target;
        var jsonResponse:Array<Dynamic> = Json.parse(loader.data);

        if (jsonResponse.length > 0) {
            currentCatImageUrl = jsonResponse[0].url;
            var imageRequest = new URLRequest(currentCatImageUrl);
            var imageLoader = new URLLoader();
            imageLoader.dataFormat = URLLoaderDataFormat.BINARY;
            imageLoader.addEventListener(Event.COMPLETE, onCatImageBinaryLoaded);
            imageLoader.load(imageRequest);
        }
    }

    private function onCatImageBinaryLoaded(event:Event):Void {
        var loader:URLLoader = cast event.target;
        var bitmapData:BitmapData = BitmapData.fromBytes(loader.data, 0, 0);
        catImage.bitmapData = bitmapData;
        catImage.scaleX = 300 / bitmapData.width;
        catImage.scaleY = 300 / bitmapData.height;
    }

    private function onGenerateClick(event:Event):Void {
        loadCatImage();
    }

    private function onSaveClick(event:Event):Void {
        if (catImage.bitmapData != null) {
            // En Android, esto requeriría permisos y el uso de la API nativa de Android.
            // Haxe/OpenFL no tiene una función directa para guardar en la galería del sistema.
            // Esto es un placeholder y necesitaría una implementación nativa a través de extensiones de Lime.
            // Por ejemplo, usando lime.system.System.saveBitmapData() o una extensión personalizada.
            // Para propósitos de demostración, guardaremos en el almacenamiento de la aplicación.
            var path = FileSystem.documentDirectory + "/cat_image_" + Date.now().getTime() + ".png";
            var bytes = catImage.bitmapData.encode(new Rectangle(0, 0, catImage.bitmapData.width, catImage.bitmapData.height), true);
            File.saveBytes(path, bytes);
            aiResponseText.text = "Imagen guardada en: " + path;
        } else {
            aiResponseText.text = "No hay imagen para guardar.";
        }
    }

    private function onSendAIClick(event:Event):Void {
        var question = aiInput.text;
        if (question.length > 0) {
            aiResponseText.text = "Pensando...";
            callCloudflareAI(question);
        } else {
            aiResponseText.text = "Por favor, escribe tu pregunta.";
        }
    }

    private function callCloudflareAI(question:String):Void {
        // Aquí iría la lógica para llamar a la API de Cloudflare Workers AI.
        // Necesitarías una librería HTTP para Haxe (como `haxe.Http` o `tink_http`).
        // Los detalles de la API (Account ID, API Key, modelo) se usarían aquí.
        // Ejemplo conceptual:
        /*
        var url = "https://api.cloudflare.com/client/v4/accounts/035b8c5bce80f27fa0a51d1aab5fdc90/ai/run/@cf/meta/llama-2-7b-chat-int8";
        var request = new URLRequest(url);
        request.method = "POST";
        request.requestHeaders.push({ name: "Authorization", value: "Bearer xHuUiqIkOoxbkswAgt9GVb86abVivwbCz3c5c1OJ" });
        request.requestHeaders.push({ name: "Content-Type", value: "application/json" });

        var payload = { prompt: question };
        request.data = Json.stringify(payload);

        var loader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.TEXT;
        loader.addEventListener(Event.COMPLETE, onAIResponseLoaded);
        loader.addEventListener(Event.IO_ERROR, onAIError);
        loader.load(request);
        */

        // Simulación de respuesta de IA para demostración
        var simulatedResponse = "Soy una IA de gatos y me encanta generar imágenes de michis. ¿En qué más puedo ayudarte?";
        aiResponseText.text = simulatedResponse;
    }

    private function onAIResponseLoaded(event:Event):Void {
        var loader:URLLoader = cast event.target;
        var jsonResponse:Dynamic = Json.parse(loader.data);
        // Asumiendo que la respuesta de la IA está en jsonResponse.result.response
        aiResponseText.text = jsonResponse.result.response;
    }

    private function onAIError(event:Event):Void {
        aiResponseText.text = "Error al comunicarse con la IA: " + event.toString();
    }
}


