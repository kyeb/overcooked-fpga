from japronto import Application

from sqlalchemy import create_engine, Column, Integer
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from sqlalchemy.ext.declarative import declarative_base

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

class Player(Base):
    __tablename__ = "players"

    id = Column(Integer, primary_key=True)
    state = Column(Integer)

    # enable decent-looking print statements
    def __repr__(self):
        return f"<Player id={self.id}, state={self.state}>"

def initializeDB():
    Base.metadata.create_all(engine)
    session = Session()
    for i in range(4):
        state = (i << 30) | ((200 + 32*i) << 19) | (200 << 10)
        b = Player(id=i, state=state)
        session.add(b)
    session.commit()
    print("DB initialized!")

initializeDB()

#######################################
# Methods
#######################################

def player_num(state):
    return state >> 30

def get_all_states():
    session = Session()
    players = session.query(Player).all()
    resp = ""
    for player in players:
        resp += f"{player.state}".zfill(10)
        resp += "|"
    return resp[:-1]

def update_state(state):
    session = Session()
    players = session.query(Player).all()
    for player in players:
        if player_num(player.state) == player_num(state):
            break
    player.state = state
    session.commit()
    return player


#######################################
# Routes
#######################################

def player_state(request):
    state = int(request.form["state"])
    if state < 0 or state > 2**32:
        r = "error: state out of acceptable range"
        return request.Response(text=r)
    if state != 0:
        player = update_state(state)

    r = get_all_states()
    return request.Response(text=r)

#######################################
# Main
#######################################

app = Application()
r = app.router
r.add_route('/overcooked/playerstate', player_state, 'POST')

app.run()
