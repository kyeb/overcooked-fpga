from flask import Flask, request
from sqlalchemy import create_engine, Column, Integer
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from sqlalchemy.ext.declarative import declarative_base

app = Flask(__name__)
engine = create_engine(
    "sqlite://", 
    connect_args={"check_same_thread": False}, 
    poolclass=StaticPool
)
Session = sessionmaker(bind=engine)
Base = declarative_base()

#######################################
# Database
#######################################

class Button(Base):
    __tablename__ = "button"

    id = Column(Integer, primary_key=True)
    pressed = Column(Integer)

    # enable decent-looking print statements
    def __repr__(self):
        return f"<Button id={self.id}, pressed={self.pressed}>"

def initializeDB():
    Base.metadata.create_all(engine)
    session = Session()
    b = Button(pressed=0)
    session.add(b)
    session.commit()


#######################################
# Routes
#######################################

@app.route("/overcooked/button", methods=['GET', 'POST'])
def button():
    session = Session()
    if request.method == "GET":
        pressed = session.query(Button).first().pressed
        return str(pressed)
    elif request.method == "POST":
        b = session.query(Button).first()
        b.pressed = int(request.form["pressed"])
        session.commit()
        return "ok"
    else:
        return "error"

#######################################
# Main
#######################################

if __name__ == '__main__':
    initializeDB()
    app.run(host='0.0.0.0')
