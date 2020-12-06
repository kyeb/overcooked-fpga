from japronto import Application

from sqlalchemy import create_engine, Column, Integer, String
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

    def __repr__(self):
        return f"<Player id={self.id}, state={self.state}>"

class Board(Base):
    __tablename__ = "boards"
    id = Column(Integer, primary_key=True)
    state = Column(String)

    def __repr__(self):
        return f"<Board id={self.id}, state={self.state}>"

def initializeDB():
    Base.metadata.create_all(engine)
    session = Session()
    for i in range(4):
        state = (i << 30) | ((200 + 32*i) << 19) | (200 << 10)
        p = Player(id=i, state=state)
        session.add(p)
    b = Board(id=0, state="0001114272|0000000000|0000000000|0000000000|0000000000|0000000000|0000000000|0000000000|1342177280|0000000000|1342177280|0000000000|0000000048|0000065535|0964870144|")
    session.add(b)
    session.commit()
    print("DB initialized!")

initializeDB()

#######################################
# Methods
#######################################

def player_num(state):
    return state >> 30

def get_player_states():
    session = Session()
    players = session.query(Player).all()
    resp = ""
    for player in players:
        resp += f"{player.state}".zfill(10)
        resp += "|"
    return resp[:-1]

def update_player_state(state):
    session = Session()
    players = session.query(Player).all()
    for player in players:
        if player_num(player.state) == player_num(state):
            break
    player.state = state
    session.commit()
    return player

def get_board_state():
    session = Session()
    return session.query(Board).get(0).state

# Actually sets board state + player 0 state
def set_board_state(state):
    session = Session()

    b = session.query(Board).get(0)
    b.state = state

    player_state = int(state.split("|")[-2])
    players = session.query(Player).all()
    for player in players:
        if player_num(player.state) == player_num(player_state):
            break
    player.state = player_state

    session.commit()

#######################################
# Routes
#######################################

def player_state(request):
    state = int(request.form["player_state"])
    if state < 0 or state > 2**32:
        r = "error: state out of acceptable range"
        return request.Response(text=r)
    if state != 0:
        player = update_player_state(state)

    r = get_player_states()
    return request.Response(text=r)

def board_state(request):
    state = request.form["board_state"]
    if state != "none":
        set_board_state(state)
    r = get_board_state()
    return request.Response(text=r)

#######################################
# Main
#######################################

app = Application()
r = app.router
r.add_route('/overcooked/playerstate', player_state, 'POST')
r.add_route('/overcooked/boardstate',  board_state,  'POST')

app.run()
