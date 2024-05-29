// Cesar Cornejo López
// Mauricio Martinez Ledezma
// Angel Rogelio de Anda Torres
import processing.sound.*;
SoundFile musica, soundNav1, soundNav2, soundWin, soundLost;
PImage fondo;
PImage naveSuperior; // Imagen de la nave superior
PImage naveInferior; // Imagen de la nave inferior
PImage explosionImg; // Imagen de la explosión
PImage originalNaveSuperior; // Imagen original de la nave superior
PImage originalNaveInferior; // Imagen original de la nave inferior
float posXNaveSuperior; // Posición horizontal de la nave superior
float posXNaveInferior; // Posición horizontal de la nave inferior
ArrayList<Float> balasX; // Lista de posiciones horizontales de las balas de la nave inferior
ArrayList<Float> balasY; // Lista de posiciones verticales de las balas de la nave inferior
float balaVelocidad = 5; // Velocidad de las balas hacia arriba
ArrayList<Float> balasXSuperior = new ArrayList<Float>(); // Lista de posiciones horizontales de las balas de la nave superior
ArrayList<Float> balasYSuperior = new ArrayList<Float>(); // Lista de posiciones verticales de las balas de la nave superior
ArrayList<Float> balasTiempoSuperior = new ArrayList<Float>(); // Lista de tiempos de las balas de la nave superior
float parabolaAnchura = 200; // Anchura de la parábola
float parabolaAltura = 200; // Altura máxima de la parábola
float gravedad = 0.2; // Gravedad que afecta la parábola
int vidasNaveSuperior = 3; // Vidas de la nave superior
int vidasNaveInferior = 3; // Vidas de la nave inferior
float velocidadNaveSuperior = 2.0; // Velocidad inicial de la nave superior
float tiempoUltimoAumentoVelocidad = 0;
float intervaloAumentoVelocidad = 7000; // Intervalo de 7 segundos
int estadoJuego = 0;
// Variables para los botones
int botonX, botonY, botonAncho, botonAlto;

void setup() {
  fullScreen(); // Especificamos la medida del lienzo
  // Configuración de los botones
  botonAncho = 200;
  botonAlto = 50;
  botonX = width / 2 - botonAncho / 2;
  botonY = height / 2 - botonAlto / 2;
  musica = new SoundFile(this, "C:/Users/cesar/OneDrive/Escritorio/Ph4/sources/main-music.mp3"); // Instanceamos la musica principal del juego
  musica.loop(); // Ponemos en bucle la musica
  soundNav1 = new SoundFile(this, "C:/Users/cesar/OneDrive/Escritorio/Ph4/sources/nav1-sound.mp3"); // Instanceamos el sonido de la nave 1
  soundNav2 = new SoundFile(this, "C:/Users/cesar/OneDrive/Escritorio/Ph4/sources/nav2-sound.mp3"); // Instanceamos el sonido de la nave 2
  soundWin = new SoundFile(this, "C:/Users/cesar/OneDrive/Escritorio/Ph4/sources/win-sound.mp3"); // Instanceamos el sonido de victoria
  soundLost = new SoundFile(this, "C:/Users/cesar/OneDrive/Escritorio/Ph4/sources/lost-sound.mp3"); // Instanceamos el sonido de derrota

  naveSuperior = loadImage("C:/Users/cesar/OneDrive/Escritorio/Ph4/sources/nave1.png"); // Cargar la imagen de la nave superior
  naveSuperior.resize(100, 0);
  originalNaveSuperior = naveSuperior; // Guardar la imagen original

  naveInferior = loadImage("C:/Users/cesar/OneDrive/Escritorio/Ph4/sources/nave2.png"); // Cargar la imagen de la nave inferior
  naveInferior.resize(100, 0);
  originalNaveInferior = naveInferior; // Guardar la imagen original

  explosionImg = loadImage("C:/Users/cesar/OneDrive/Escritorio/Ph4/sources/explosion.png"); // Cargar la imagen de la explosión
  explosionImg.resize(100, 0);

  posXNaveSuperior = -naveSuperior.width; // Inicializar la posición horizontal de la nave superior fuera del lienzo
  posXNaveInferior = width; // Inicializar la posición horizontal de la nave inferior fuera del lienzo
  balasX = new ArrayList<Float>(); // Inicializar la lista de posiciones horizontales de las balas
  balasY = new ArrayList<Float>(); // Inicializar la lista de posiciones verticales de las balas
}

float calcularAnguloDisparo(float posXNaveSuperior, float posXNaveInferior) {
  // Calcular la diferencia de posiciones en x
  float deltaX = posXNaveInferior - posXNaveSuperior;

  // Calcular la altura de la nave superior
  float alturaNaveSuperior = 50 + naveSuperior.height / 2;

  // Calcular la altura objetivo (mitad de la nave inferior)
  float alturaObjetivo = height / 2;

  // Calcular la tangente del ángulo de disparo
  float tanAngulo = (alturaObjetivo - alturaNaveSuperior) / deltaX;

  // Calcular el ángulo de disparo en radianes
  float angulo = atan(tanAngulo);

  // Ajustar el ángulo para que se dispare hacia abajo
  if (angulo > 0) {
    angulo = PI - angulo;
  }

  // Devolver el ángulo en radianes
  return angulo;
}

void dispararNaveSuperior() {
  // Calcular la posición horizontal y vertical relativa de la nave inferior
  float deltaX = posXNaveInferior - posXNaveSuperior;
  float deltaY = height - 50 - naveSuperior.height - (50 + naveInferior.height / 2);

  // Calcular el tiempo de vuelo necesario para que la bala alcance la posición vertical de la nave inferior
  float tiempoVuelo = deltaY / balaVelocidad;

  // Calcular la posición horizontal donde la bala debe ser disparada para interceptar a la nave inferior
  float posXObjetivo = posXNaveInferior + naveInferior.width / 2 + (tiempoVuelo * 2);

  // Calcular el ángulo de disparo
  float anguloDisparo = calcularAnguloDisparo(posXNaveSuperior, posXObjetivo);

  // Calcular la posición inicial del proyectil
  float balaXSuperior = posXNaveSuperior + naveSuperior.width / 2;
  float balaYSuperior = 50 + naveSuperior.height / 2;

  // Agregar la posición inicial del proyectil a las listas
  balasXSuperior.add(balaXSuperior);
  balasYSuperior.add(balaYSuperior); // Posición inicial en y (centro de la nave superior)
  balasTiempoSuperior.add(0.0); // Tiempo inicial
}

void draw() {
  if (estadoJuego == 0) {
    // Dibujar el menú
    dibujarMenu();
  } else if (estadoJuego == 1) {
    // Dibujar el juego principal
    dibujarJuego1();
  } else if (estadoJuego == 2) {
    dibujarJuego2();
  }
}

void dibujarMenu() {
  background(0); // Fondo negro

  // Configurar el texto del menú
  fill(255);
  textSize(32);
  textAlign(CENTER, CENTER);

  // Dibujar las opciones del menú
  text("¡Bienvenido a Space Kombat!", width/2, height/2 - 50);
  // Dibujar el botón "Comenzar juego"
  fill(255, 255, 255);
  rect(botonX, botonY, botonAncho, botonAlto);
  fill(184, 180, 180);
  text("Dos jugadores", width / 2, height / 2);
  fill(255, 255, 255);
  rect(botonX, botonY + 90, botonAncho, botonAlto);
  fill(184, 180, 180);
  text("Un jugador", width / 2, botonY + 110);
  fill(184, 180, 180);
}

void dibujarJuego1() {
  fondo = loadImage("C:/Users/cesar/OneDrive/Escritorio/Ph4/sources/fondo.jpg");
  fondo.resize(width, height);
  background(fondo); // Establecer el fondo

  // Actualizar la posición horizontal de la nave superior
  if (vidasNaveSuperior > 0) {
    posXNaveSuperior += 2; // Velocidad horizontal de la nave superior

    // Verificar si la nave superior ha salido completamente del lado derecho del lienzo
    if (posXNaveSuperior > width) {
      posXNaveSuperior = -naveSuperior.width; // Volver a colocar la nave en el lado izquierdo del lienzo
    }
  }

  // Dibujar la nave superior en su nueva posición horizontal
  image(naveSuperior, posXNaveSuperior, 50);

  // Actualizar la posición horizontal de la nave inferior
  if (vidasNaveInferior > 0) {
    // Aumentar velocidad cada 7 segundos
    if (millis() - tiempoUltimoAumentoVelocidad > intervaloAumentoVelocidad) {
      velocidadNaveSuperior += 0.5; // Incrementar la velocidad
      tiempoUltimoAumentoVelocidad = millis(); // Actualizar el tiempo del último aumento de velocidad
    }
    posXNaveSuperior += velocidadNaveSuperior; // Velocidad horizontal de la nave superior
    posXNaveInferior -= 2; // Velocidad horizontal de la nave inferior

    // Verificar si la nave inferior ha salido completamente del lado izquierdo del lienzo
    if (posXNaveInferior < -naveInferior.width) {
      posXNaveInferior = width; // Volver a colocar la nave en el lado derecho del lienzo
    }
  }

  // Dibujar la nave inferior en su nueva posición horizontal
  image(naveInferior, posXNaveInferior, height - 50 - naveInferior.height);

  // Actualizar y mostrar todas las balas disparadas por la nave superior
  for (int i = 0; i < balasXSuperior.size(); i++) {
    // Obtener el tiempo actual de la bala
    float tiempo = balasTiempoSuperior.get(i);

    // Calcular la nueva posición de la bala en base a una trayectoria parabólica hacia abajo y a la izquierda
    float nuevaBalaXSuperior = balasXSuperior.get(i) - tiempo * 2; // Aumenta la velocidad en el eje X
    float nuevaBalaYSuperior = balasYSuperior.get(i) + tiempo + (gravedad * tiempo * tiempo); // Ajustar la parábola hacia abajo

    // Dibujar la bala como una elipse (amarillo)
    fill(255, 255, 0); // Color amarillo
    ellipse(nuevaBalaXSuperior, nuevaBalaYSuperior, 10, 10); // Bolita en la posición de la bala

    // Actualizar el tiempo de la bala
    tiempo += 1; // Incrementar el tiempo

    // Actualizar el tiempo de la bala en la lista
    balasTiempoSuperior.set(i, tiempo);

    // Verificar colisión con la nave inferior
    if (nuevaBalaXSuperior > posXNaveInferior && nuevaBalaXSuperior < posXNaveInferior + naveInferior.width &&
      nuevaBalaYSuperior > height - 50 - naveInferior.height && nuevaBalaYSuperior < height - 50) {
      // Reducir una vida de la nave inferior
      vidasNaveInferior--;
      // Eliminar la bala de las listas
      balasXSuperior.remove(i);
      balasYSuperior.remove(i);
      balasTiempoSuperior.remove(i);
      i--; // Decrementar el índice para evitar saltar una bala
      continue; // Saltar a la siguiente iteración
    }

    // Verificar si la bala ha salido del lienzo
    if (nuevaBalaYSuperior > height || nuevaBalaXSuperior < 0) {
      // Eliminar la bala de las listas
      balasXSuperior.remove(i);
      balasYSuperior.remove(i);
      balasTiempoSuperior.remove(i);
      i--; // Decrementar el índice para evitar saltar una bala
    }
  }

  // Actualizar y mostrar todas las balas disparadas por la nave inferior
  for (int i = 0; i < balasX.size(); i++) {
    // Obtener la posición actual de la bala
    float balaX = balasX.get(i);
    float balaY = balasY.get(i);

    // Dibujar la bala como una elipse (rojo)
    fill(255, 0, 0); // Color rojo
    ellipse(balaX, balaY, 10, 10); // Bolita en la posición de la bala

    // Actualizar la posición vertical de la bala
    balaY -= balaVelocidad; // Mover la bala hacia arriba

    // Actualizar la posición de la bala en la lista
    balasY.set(i, balaY);

    // Verificar colisión con la nave superior
    if (balaX > posXNaveSuperior && balaX < posXNaveSuperior + naveSuperior.width &&
      balaY > 50 && balaY < 50 + naveSuperior.height) {
      // Reducir una vida de la nave superior
      vidasNaveSuperior--;
      // Eliminar la bala de las listas
      balasX.remove(i);
      balasY.remove(i);
      i--; // Decrementar el índice para evitar saltar una bala
      continue; // Saltar a la siguiente iteración
    }

    // Verificar si la bala ha salido del lienzo
    if (balaY < 0) {
      // Eliminar la bala de las listas
      balasX.remove(i);
      balasY.remove(i);
      i--; // Decrementar el índice para evitar saltar una bala
    }
  }

  // Mostrar las vidas restantes
  fill(255);
  textSize(20);
  text("Vidas Jugador 2 > " + vidasNaveSuperior, 90, 30);
  text("Vidas Jugador 1 > " + vidasNaveInferior, 90, height - 30);

  // Verificar si alguna nave ha perdido todas sus vidas
  if (vidasNaveSuperior <= 0 || vidasNaveInferior <= 0) {
    noLoop();
    musica.stop();

    mostrarExplosion();


    // Configurar el tamaño del texto
    textSize(40);

    // Mostrar el mensaje de victoria o derrota
    if (vidasNaveSuperior <= 0) {
      soundWin.play();
      text("¡Ha Ganado Jugador 1!", width / 2, height / 2);
    } else {
      soundLost.play();
      text("¡Ha Ganado Jugador 2!", width / 2, height / 2);
    }
  }
}

void dibujarJuego2() {
  fondo = loadImage("C:/Users/cesar/OneDrive/Escritorio/Ph4/sources/fondo.jpg");
  fondo.resize(width, height);
  background(fondo); // Establecer el fondo

  // Actualizar la posición horizontal de la nave superior
  if (vidasNaveSuperior > 0) {
    posXNaveSuperior += 2; // Velocidad horizontal de la nave superior

    // Verificar si la nave superior ha salido completamente del lado derecho del lienzo
    if (posXNaveSuperior > width) {
      posXNaveSuperior = -naveSuperior.width; // Volver a colocar la nave en el lado izquierdo del lienzo
    }
  }

  // Dibujar la nave superior en su nueva posición horizontal
  image(naveSuperior, posXNaveSuperior, 50);

  // Actualizar la posición horizontal de la nave inferior
  if (vidasNaveInferior > 0) {
    // Aumentar velocidad cada 7 segundos
    if (millis() - tiempoUltimoAumentoVelocidad > intervaloAumentoVelocidad) {
      velocidadNaveSuperior += 0.5; // Incrementar la velocidad
      tiempoUltimoAumentoVelocidad = millis(); // Actualizar el tiempo del último aumento de velocidad
    }
    posXNaveSuperior += velocidadNaveSuperior; // Velocidad horizontal de la nave superior
    posXNaveInferior -= 2; // Velocidad horizontal de la nave inferior

    // Verificar si la nave inferior ha salido completamente del lado izquierdo del lienzo
    if (posXNaveInferior < -naveInferior.width) {
      posXNaveInferior = width; // Volver a colocar la nave en el lado derecho del lienzo
    }
  }

  // Dibujar la nave inferior en su nueva posición horizontal
  image(naveInferior, posXNaveInferior, height - 50 - naveInferior.height);

  // Disparar desde la nave superior con la nueva frecuencia de disparo
  if (millis() % 200 == 0) {
    dispararNaveSuperior();
  }

  // Actualizar y mostrar todas las balas disparadas por la nave superior
  for (int i = 0; i < balasXSuperior.size(); i++) {
    // Obtener el tiempo actual de la bala
    float tiempo = balasTiempoSuperior.get(i);

    // Calcular la nueva posición de la bala en base a una trayectoria parabólica hacia abajo y a la izquierda
    float nuevaBalaXSuperior = balasXSuperior.get(i) - tiempo * 2; // Aumenta la velocidad en el eje X
    float nuevaBalaYSuperior = balasYSuperior.get(i) + tiempo + (gravedad * tiempo * tiempo); // Ajustar la parábola hacia abajo

    // Dibujar la bala como una elipse (amarillo)
    fill(255, 255, 0); // Color amarillo
    ellipse(nuevaBalaXSuperior, nuevaBalaYSuperior, 10, 10); // Bolita en la posición de la bala

    // Actualizar el tiempo de la bala
    tiempo += 1; // Incrementar el tiempo

    // Actualizar el tiempo de la bala en la lista
    balasTiempoSuperior.set(i, tiempo);

    // Verificar colisión con la nave inferior
    if (nuevaBalaXSuperior > posXNaveInferior && nuevaBalaXSuperior < posXNaveInferior + naveInferior.width &&
      nuevaBalaYSuperior > height - 50 - naveInferior.height && nuevaBalaYSuperior < height - 50) {
      // Reducir una vida de la nave inferior
      vidasNaveInferior--;
      // Eliminar la bala de las listas
      balasXSuperior.remove(i);
      balasYSuperior.remove(i);
      balasTiempoSuperior.remove(i);
      i--; // Decrementar el índice para evitar saltar una bala
      continue; // Saltar a la siguiente iteración
    }

    // Verificar si la bala ha salido del lienzo
    if (nuevaBalaYSuperior > height || nuevaBalaXSuperior < 0) {
      // Eliminar la bala de las listas
      balasXSuperior.remove(i);
      balasYSuperior.remove(i);
      balasTiempoSuperior.remove(i);
      i--; // Decrementar el índice para evitar saltar una bala
    }
  }

  // Actualizar y mostrar todas las balas disparadas por la nave inferior
  for (int i = 0; i < balasX.size(); i++) {
    // Obtener la posición actual de la bala
    float balaX = balasX.get(i);
    float balaY = balasY.get(i);

    // Dibujar la bala como una elipse (rojo)
    fill(255, 0, 0); // Color rojo
    ellipse(balaX, balaY, 10, 10); // Bolita en la posición de la bala

    // Actualizar la posición vertical de la bala
    balaY -= balaVelocidad; // Mover la bala hacia arriba

    // Actualizar la posición de la bala en la lista
    balasY.set(i, balaY);

    // Verificar colisión con la nave superior
    if (balaX > posXNaveSuperior && balaX < posXNaveSuperior + naveSuperior.width &&
      balaY > 50 && balaY < 50 + naveSuperior.height) {
      // Reducir una vida de la nave superior
      vidasNaveSuperior--;
      // Eliminar la bala de las listas
      balasX.remove(i);
      balasY.remove(i);
      i--; // Decrementar el índice para evitar saltar una bala
      continue; // Saltar a la siguiente iteración
    }

    // Verificar si la bala ha salido del lienzo
    if (balaY < 0) {
      // Eliminar la bala de las listas
      balasX.remove(i);
      balasY.remove(i);
      i--; // Decrementar el índice para evitar saltar una bala
    }
  }

  // Mostrar las vidas restantes
  fill(255);
  textSize(20);
  text("Vidas computadora > " + vidasNaveSuperior, 10, 30);
  text("Vidas Jugador 1 > " + vidasNaveInferior, 10, height - 30);

  // Verificar si alguna nave ha perdido todas sus vidas
  if (vidasNaveSuperior <= 0 || vidasNaveInferior <= 0) {
    noLoop(); // Stop the draw loop
    musica.stop();

    mostrarExplosion();

    // Update the ship image with the explosion image first
    if (vidasNaveSuperior <= 0) {
      naveSuperior = explosionImg;
    } else {
      naveInferior = explosionImg;
    }

    // Set the text size
    textSize(40);

    // Display the victory or defeat message
    if (vidasNaveSuperior <= 0) {
      soundWin.play();
      text("¡Has Ganado!", width / 2 - 150, height / 2);
    } else {
      soundLost.play();
      text("¡Has Perdido!", width / 2 - 150, height / 2);
    }
  }
}

// Función para reiniciar el juego
void reiniciarJuego() {
  // Reiniciar las vidas de las naves
  vidasNaveSuperior = 3;
  vidasNaveInferior = 3;

  // Limpiar las listas de balas
  balasX.clear();
  balasY.clear();
  balasXSuperior.clear();
  balasYSuperior.clear();
  balasTiempoSuperior.clear();

  // Restaurar las imágenes originales de las naves
  naveSuperior = originalNaveSuperior;
  naveInferior = originalNaveInferior;

  // Reanudar el bucle draw
  loop();
}

void mostrarExplosion() {
  if (vidasNaveSuperior <= 0) {
    image(explosionImg, posXNaveSuperior, 50);
  }
  if (vidasNaveInferior <= 0) {
    image(explosionImg, posXNaveInferior, height - 50 - naveInferior.height);
  }
}

// Función para manejar el clic del mouse
void mousePressed() {
  if (estadoJuego == 0) {
    // Verificar si se hizo clic en el botón "Dos Jugadores"
    if (mouseX > botonX && mouseX < botonX + botonAncho && mouseY > botonY && mouseY < botonY + botonAlto) {
      estadoJuego = 1; // Cambiar al juego principal (modo de dos jugadores)
    }
    // Verificar si se hizo clic en el botón "Un jugador"
    else if (mouseX > botonX && mouseX < botonX + botonAncho && mouseY > botonY + 100 && mouseY < botonY + 100 + botonAlto) {
      estadoJuego = 2; // Cambiar al juego principal (modo de un jugador)
    }
  } else {
    // Si el estado del juego no es 0 (es decir, se está jugando), entonces verificar el disparo de las naves
    if (estadoJuego == 1) {
      // Verificar si se hizo clic en la nave inferior para disparar
      if (mouseY > height - 50 - naveInferior.height && mouseY < height - 50 && mouseX > posXNaveInferior && mouseX < posXNaveInferior + naveInferior.width) {
        // Reproducir el efecto de la nave
        soundNav1.play();
        // Agregar la posición inicial de la bala a las listas
        balasX.add((float)(posXNaveInferior + naveInferior.width / 2));
        balasY.add((float)(height - 50 - naveInferior.height / 2));
      } // Verificar si se hizo clic en la nave superior para disparar
      else if (mouseY > 50 && mouseY < 50 + naveSuperior.height && mouseX > posXNaveSuperior && mouseX < posXNaveSuperior + naveSuperior.width) {
        // Reproducir el efecto de la nave
        soundNav2.play();
        // Agregar la posición inicial de la bala de la nave superior a las listas
        balasXSuperior.add((float)(posXNaveSuperior + naveSuperior.width / 2));
        balasYSuperior.add((float)(50 + naveSuperior.height / 2));
        balasTiempoSuperior.add(0.0); // Tiempo inicial
      }
    } else if (estadoJuego == 2) {
      // Verificar si se hizo clic en la nave inferior para disparar
      if (mouseY > height - 50 - naveInferior.height && mouseY < height - 50 && mouseX > posXNaveInferior && mouseX < posXNaveInferior + naveInferior.width) {
        // Reproducir el efecto de la nave
        soundNav1.play();
        // Agregar la posición inicial de la bala a las listas
        balasX.add((float)(posXNaveInferior + naveInferior.width / 2));
        balasY.add((float)(height - 50 - naveInferior.height / 2));
      }
    }
  }
}

void mouseClicked() {
  // Si el juego ha terminado y se hace clic en cualquier parte del lienzo, reiniciar el juego
  if (vidasNaveSuperior <= 0 || vidasNaveInferior <= 0) {
    // Reproducir la musica
    musica.play();
    reiniciarJuego();
  }
}
