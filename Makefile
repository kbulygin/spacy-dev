build:
	docker build -t spacy-dev .

run: build
	docker run --rm -it --name=spacy-dev spacy-dev bash
