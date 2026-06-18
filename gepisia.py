"""
GEPISIA - Projeto de Inteligência Artificial do Grupo GEPIS
Demonstração de conceitos básicos de Machine Learning com Python.
"""

from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import accuracy_score, classification_report
import numpy as np


def carregar_dados():
    """Carrega o conjunto de dados Iris como exemplo didático."""
    iris = load_iris()
    print("=== Dataset Iris ===")
    print(f"Número de amostras: {len(iris.data)}")
    print(f"Número de características: {iris.data.shape[1]}")
    print(f"Classes: {list(iris.target_names)}\n")
    return iris


def treinar_modelo(iris):
    """Treina um classificador K-Nearest Neighbors."""
    X_treino, X_teste, y_treino, y_teste = train_test_split(
        iris.data, iris.target, test_size=0.3, random_state=42
    )

    modelo = KNeighborsClassifier(n_neighbors=3)
    modelo.fit(X_treino, y_treino)

    previsoes = modelo.predict(X_teste)
    acuracia = accuracy_score(y_teste, previsoes)

    print("=== Resultados do Modelo KNN ===")
    print(f"Acurácia: {acuracia * 100:.2f}%\n")
    print("Relatório de classificação:")
    print(classification_report(y_teste, previsoes, target_names=iris.target_names))

    return modelo


def fazer_previsao(modelo, iris):
    """Faz uma previsão de exemplo com o modelo treinado."""
    exemplo = np.array([[5.1, 3.5, 1.4, 0.2]])
    previsao = modelo.predict(exemplo)
    especie = iris.target_names[previsao[0]]

    print("=== Previsão de Exemplo ===")
    print(f"Características de entrada: {exemplo[0]}")
    print(f"Espécie prevista: {especie}")


if __name__ == "__main__":
    print("GEPISIA - Inteligência Artificial no GEPIS\n")
    iris = carregar_dados()
    modelo = treinar_modelo(iris)
    fazer_previsao(modelo, iris)
